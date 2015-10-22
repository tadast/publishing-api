class DraftContentItem < ActiveRecord::Base
  include Replaceable
  include DefaultAttributes
  include SymbolizeJSON
  include ImmutableBasePath

  TOP_LEVEL_FIELDS = (LiveContentItem::TOP_LEVEL_FIELDS + [
    :access_limited,
  ]).freeze

  has_one :live_content_item

  before_validation :increment_version

  validates :content_id, presence: true

  def refreshed_live_item
    if live_content_item
      LiveContentItem.find_by(content_id: live_content_item.content_id) || live_content_item
    end
  end

private
  def self.query_keys
    [:content_id, :locale]
  end

  def content_ids_match
    if live_content_item && live_content_item.content_id != content_id
      errors.add(:content_id, "id mismatch between draft and live content items")
    end
  end

  def increment_version
    self.version ||= 0
    self.version += 1
  end
end
