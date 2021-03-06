require "rails_helper"
require "govuk/client/test_helpers/url_arbiter"

RSpec.describe PathReservationsController, type: :controller do
  include GOVUK::Client::TestHelpers::URLArbiter

  describe "reserve_path" do
    before do
      stub_default_url_arbiter_responses
    end

    context "with a valid path reservation request" do
      let(:payload) {
        { publishing_app: "Foo" }
      }

      it "responds successfully" do
        request.env["RAW_POST_DATA"] = payload.to_json
        post :reserve_path, base_path: "foo"

        expect(response.status).to eq(200)
      end
    end

    context "with an invalid path reservation request" do
      let(:payload) {
        { publishing_app: nil }
      }

      it "responds with status 422" do
        request.env["RAW_POST_DATA"] = payload.to_json
        post :reserve_path, base_path: "///"

        expect(response.status).to eq(422)
      end
    end
  end

end
