module Replaceable
  extend ActiveSupport::Concern

  included do
    def assign_attributes_with_defaults(attributes)
      new_attributes = self.class.column_defaults
        .merge(attributes.stringify_keys)
        .merge(attribute_overrides)
      assign_attributes(new_attributes)
    end

  private
    def attribute_overrides
      {
        "version" => increment_version,
        "id" => self.id
      }
    end

    def increment_version
      (self.version || 0) + 1
    end
  end

  class_methods do
    def create_or_replace(payload)
      payload = payload.stringify_keys
      item = self.lock.find_or_initialize_by(content_id: payload["content_id"], locale: payload["locale"])
      if block_given?
        yield(item)
      end
      item.assign_attributes_with_defaults(payload)
      item.save!
      item
    rescue ActiveRecord::StatementInvalid => e
      if !item.persisted? && e.original_exception.is_a?(PG::UniqueViolation)
        raise Command::Retry.new("Race condition in create_or_replace, retrying (original error: '#{e.message}')")
      else
        raise
      end
    end
  end
end