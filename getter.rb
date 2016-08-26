# frozen_string_literal: true
require 'base64'
require 'net/http'
require 'uri'
require 'json'
require 'open-uri'

# ツイートの取得を行う
class TweetsGetter
  def initialize(api_key, api_secret)
    bearer_getter = BearerGetter.new(api_key, api_secret)
    body = bearer_getter.send_request.body
    @bearer_token = extract_bearer_token(body)
  end

  def get_tweets(
    q:, options: {
      geocode: nil, lang: nil, locale: nil, result_type: nil, count: nil,
      until: nil, since_id: nil, max_id: nil, include_entities: nil,
      callback: nil
    }
  )
    parameters = options
    parameters[:q] = q
    send_request(parameters)
  end

  private

  def before_send_request(parameters)
    parameters = prepare_request(parameters)
    url = 'https://api.twitter.com/1.1/search/tweets.json'
    url = URI.parse("#{url}?#{URI.encode(parameters)}")
    header = {
      'Authorization' => "Bearer #{@bearer_token}"
    }
    [url, header]
  end

  def extract_bearer_token(body)
    response_body = JSON.parse(body)
    response_body['access_token']
  end

  def prepare_request(parameters)
    temp_array = []
    parameters.each do |key, value|
      temp_array << "#{key}=#{value}" unless value.nil?
    end
    parameters = temp_array.join('&')
    parameters
  end

  def send_request(parameters)
    url, header = before_send_request(parameters)
    response = open(url, header)
    JSON.parse(response.read)
  end
end

# ベアラートークンを取得する
class BearerGetter
  RequestStatus = Struct.new(:https, :header, :body, :path)
  def initialize(api_key, api_secret)
    url = URI.parse('https://api.twitter.com/oauth2/token')
    bearer_token = "#{URI.encode(api_key)}:#{URI.encode(api_secret)}"
    credentials = Base64.strict_encode64(bearer_token)
    header, body = initialize_http_request(credentials)
    path, https = before_send_request(url)
    @request_data = RequestStatus.new(https, header, body, path)
  end

  def send_request
    https, header, body, path = @request_data.to_a
    https.start do
      request = Net::HTTP::Post.new(path, header)
      request.body = body
      response = https.request(request)
      response
    end
  end

  def before_send_request(url)
    path = url.path
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    [path, https]
  end

  private

  def initialize_http_request(credentials)
    header = {
      'Authorization' => "Basic #{credentials}",
      'Content-Type' => 'application/x-www-form-urlencoded;charset=UTF-8'
    }
    body = 'grant_type=client_credentials'
    [header, body]
  end
end
