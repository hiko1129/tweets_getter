# frozen_string_literal: true
$LOAD_PATH << './'
require 'getter'
require 'test/unit'

# BearerGetterのテスト
class TestGetter < Test::Unit::TestCase
  def setup
    api_key = ENV['TWITTER_API_KEY']
    api_secret = ENV['TWITTER_API_SECRET']
    @bearer_getter = BearerGetter.new(api_key, api_secret)
    @tweets_getter = TweetsGetter.new(api_key, api_secret)
  end

  # BearerGetter
  def test_before_send_request
    url = URI.parse('https://api.twitter.com/oauth2/token')
    part_of_status = @bearer_getter.before_send_request(url)
    assert_instance_of(Array, part_of_status)
  end

  def test_send_request
    response = @bearer_getter.send_request
    assert_instance_of(Net::HTTPOK, response)
  end

  # TweetsGetter
  def test_get_tweets
    response = @tweets_getter.get_tweets(q: 'こんにちは')
    assert_instance_of(Hash, response)
  end
end
