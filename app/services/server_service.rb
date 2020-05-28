class ServerService
  def initialize(instance)
    @instance = instance
  end

  def status
    act('STATUS')
  end

  def stop
    act('STOP')
  end

  def start
    act('START')
  end

  private

  def act(action)
    url = URI.parse('https://kje753t5r8.execute-api.us-east-2.amazonaws.com/api')
    url.query = { action: action, instance: @instance }.to_query
    request = Net::HTTP::Get.new(url)
    request['Content-Type'] = 'application/json'
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    response = http.request(request)
    body = JSON.parse(response.read_body)
    body
  end
end
