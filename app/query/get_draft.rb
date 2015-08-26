class Query::GetDraft
  def call(params)
    content_item = DraftContentItem.find_by_content_id(params[:content_id])
    if content_item
      Query::SuccessResponse.new(content_item.attributes.except(:id))
    else
      Query::NotFoundResponse.new
    end
  end
end
