require 'rails_helper'

RSpec.describe DraftContentItem do
  subject { FactoryGirl.build(:draft_content_item) }

  def set_new_attributes(item)
    item.title = "New title"
  end

  def verify_new_attributes_set
    expect(described_class.last.title).to eq("New title")
  end

  describe "versioning" do
    it "increments the version number when the record is saved" do
      subject.version = 5
      subject.save!

      expect(subject.reload.version).to eq(6)
    end

    it "sets the version to 1 on first save" do
      subject.save!
      expect(subject.reload.version).to eq(1)
    end
  end

  describe "validations" do
    it "is valid for the default factory" do
      expect(subject).to be_valid
    end

    it "requires a content_id" do
      subject.content_id = nil
      expect(subject).to be_invalid
    end
  end

  let(:existing) { FactoryGirl.create(:draft_content_item) }

  let(:content_id) { existing.content_id }
  let(:payload) do
    FactoryGirl.build(:draft_content_item)
    .as_json
    .symbolize_keys
    .merge(
      content_id: content_id,
      title: "New title"
    )
  end

  let(:another_payload) do
    FactoryGirl.build(:draft_content_item)
    .as_json
    .symbolize_keys
    .merge(title: "New title")
  end

  it_behaves_like Replaceable
  it_behaves_like DefaultAttributes
  it_behaves_like ImmutableBasePath
end
