require_relative '../models/chat_manager'

post '/urls/messages/:i' do
	$SERVER_LOG = Logger.new('logs/url_tester.log', 'monthly')
	response['Access-Control-Allow-Origin'] = '*'

	formatted_url = Url.rootify(params[:url])
	url = Url.find_by(link: formatted_url)

	timezoneOffset = params[:timezoneOffset].to_i
	$SERVER_LOG.info("URL: #{formatted_url} ---- Object: #{url}")
	if !url.nil?
		messages = url.messages.last(params[:i]).map do |message|
			{
				author: message.user.name,
				content: message.content,
				time: TimeDisplay.time_or_date(message.created_at, timezoneOffset)
			}
		end
		object = {messages: messages}.to_json
	else
		object = {}.to_json
	end
	content_type :json
	object
end
