require "rails_helper"
require "support/shared_context/message_queue_test_mode"

RSpec.describe "POST /v2/publish", type: :request do
  include MessageQueueHelpers

  let(:draft_content_item_attributes) { draft_content_item.attributes.deep_symbolize_keys.except(:id, :version) }
  let(:expected_live_content_item_derived_representation) {
    draft_content_item_attributes
      .merge(draft_content_item_attributes[:metadata])
      .merge(public_updated_at: draft_content_item_attributes[:public_updated_at].iso8601)
      .except(:metadata, :access_limited)
  }
  let(:expected_live_content_item_hash) {
    expected_live_content_item_derived_representation
      .deep_symbolize_keys
      .merge(
        links: link_set.links,
      )
      .except(:update_type)
  }

  let(:content_id) { draft_content_item.content_id }
  let!(:link_set) { create(:link_set, content_id: content_id) }
  let(:request_path) { "/v2/content/#{content_id}/publish"}
  let(:payload) {
    {
      update_type: "major",
    }
  }
  let(:request_body) { payload.to_json }

  def do_request(body: request_body, headers: {})
    post request_path, body, headers
  end

  context "a draft content item exists with version 1" do
    let(:draft_content_item) { FactoryGirl.create(:draft_content_item, version: 1) }

    logs_event("Publish", expected_payload_proc: ->{ payload.merge(content_id: content_id) })

    it "creates the LiveContentItem derived representation" do
      do_request

      expect(LiveContentItem.count).to eq(1)

      item = LiveContentItem.first

      expect(item.base_path).to eq(base_path)
      expect(item.content_id).to eq(expected_live_content_item_derived_representation[:content_id])
      expect(item.details).to eq(expected_live_content_item_derived_representation[:details].deep_symbolize_keys)
      expect(item.format).to eq(expected_live_content_item_derived_representation[:format])
      expect(item.locale).to eq(expected_live_content_item_derived_representation[:locale])
      expect(item.publishing_app).to eq(expected_live_content_item_derived_representation[:publishing_app])
      expect(item.rendering_app).to eq(expected_live_content_item_derived_representation[:rendering_app])
      expect(item.public_updated_at).to eq(expected_live_content_item_derived_representation[:public_updated_at])
      expect(item.description).to eq(expected_live_content_item_derived_representation[:description])
      expect(item.title).to eq(expected_live_content_item_derived_representation[:title])
      expect(item.routes).to eq(expected_live_content_item_derived_representation[:routes].map(&:deep_symbolize_keys))
      expect(item.redirects).to eq(expected_live_content_item_derived_representation[:redirects].map(&:deep_symbolize_keys))
      expect(item.metadata[:need_ids]).to eq(expected_live_content_item_derived_representation[:need_ids])
      expect(item.metadata[:phase]).to eq(expected_live_content_item_derived_representation[:phase])
    end

    it "gives the new LiveContentItem the same version number as the draft item" do
      do_request

      expect(LiveContentItem.first.version).to eq(draft_content_item.version)
    end
  end

  context "a draft exists with version 2, a live exists with version 1" do
    let(:live_content_item) do
      FactoryGirl.create(:live_content_item)
    end

    let(:draft_content_item) do
      # Saving the draft content item triggers the auto-increment.
      live_content_item.draft_content_item.update!(title: "An existing title")
      live_content_item.draft_content_item
    end

    it "updates the existing LiveContentItem" do
      expect {
        do_request
      }.to_not change(LiveContentItem, :count)

      expect(LiveContentItem.last.title).to eq("An existing title")
    end

    it "gives the updated LiveContentItem the same version number as the draft item" do
      do_request

      expect(LiveContentItem.first.version).to eq(draft_content_item.version)
    end

    it "sends item to live content store including links" do
      expect(PublishingAPI.service(:live_content_store)).to receive(:put_content_item)
      .with(
        base_path: draft_content_item.base_path,
        content_item: expected_live_content_item_hash
      )
      do_request
    end

    describe "message queue integration" do
      include_context "using the message queue in test mode"

      it "sends the item combined with the current link set on the message queue" do
        do_request
        delivery_info, _, message_json = wait_for_message_on(@queue)
        expect(delivery_info.routing_key).to eq("#{draft_content_item.format}.#{payload[:update_type]}")

        message = JSON.parse(message_json)
        expect(message).to eq(expected_live_content_item_hash.as_json.merge("update_type" => payload[:update_type]))
      end
    end

    context "update_type is absent" do
      let(:payload) { {} }

      it "reports an error" do
        do_request

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)).to match("error" => hash_including("fields" => {"update_type" => ["is required"]}))
      end
    end
  end

  context "the draft content item is already published" do
    let!(:live_content_item) { FactoryGirl.create(:live_content_item) }
    let!(:draft_content_item) { live_content_item.draft_content_item }

    it "reports an error" do
      expect(live_content_item.version).to eq(draft_content_item.version)

      do_request

      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)).to match("error" => hash_including("message" => /already published/))
    end
  end

  context "a draft content item exists in multiple locales" do
    let(:content_id) { SecureRandom.uuid }

    let!(:french_draft) { FactoryGirl.create(:draft_content_item, content_id: content_id, locale: "fr") }
    let!(:english_draft) { FactoryGirl.create(:draft_content_item, content_id: content_id, locale: "en") }
    let!(:arabic_draft) { FactoryGirl.create(:draft_content_item, content_id: content_id, locale: "ar") }

    context "when a locale is specified in the payload" do
      let(:payload) {
        {
          update_type: "major",
          locale: "fr"
        }
      }

      it "publishes the content item for the specified locale" do
        expect {
          do_request
        }.to change(LiveContentItem, :count).by(1)

        live_item = LiveContentItem.last

        expect(live_item.locale).to eq("fr")
        expect(live_item.draft_content_item).to eq(french_draft)
      end
    end

    context "when no locale is specified in the payload" do
      it "publishes the english content item" do
        expect {
          do_request
        }.to change(LiveContentItem, :count).by(1)

        live_item = LiveContentItem.last

        expect(live_item.locale).to eq("en")
        expect(live_item.draft_content_item).to eq(english_draft)
      end
    end
  end
end
