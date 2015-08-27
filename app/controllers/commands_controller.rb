class CommandsController < ApplicationController
  def process_command
    event = event_processor.process(params['command_name'], authenticated_user_id, request_json)

    render json: {event_id: event.id}
  rescue EventProcessor::InvalidUser
    render json: {error: {code: 401, message: "unauthorized"}}, status: 401
  end

private
  def authenticated_user_id
    request.headers['X-Govuk-Authenticated-User']
  end

  def request_json
    @request_json ||= JSON.parse(request.body.read)
  rescue JSON::ParserError
    head :bad_request
  end

  def event_processor
    Services.new.event_processor
  end
end