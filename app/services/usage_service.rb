class UsageService
  def call
    message = 'STATUS'
    url = URI.parse('https://kje753t5r8.execute-api.us-east-2.amazonaws.com/api?action=' + message)
    request = Net::HTTP::Get.new(url)
    request['Content-Type'] = 'application/json'
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    response = http.request(request)
    body = JSON.parse(response.read_body)
    body
  end
end
