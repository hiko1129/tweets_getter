# frozen_string_literal: true
require 'twitter'

# API経由でツイッターからツイートを取得する
class Agent
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_API_KEY']
      config.consumer_secret = ENV['TWITTER_API_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end

  def get_tweet(query_string)
    count = 100
    options = {
      count: count, result_type: 'recent',
      since_id: nil, lang: 'ja'
    }
    result_tweets = @client.search(query_string, options)
    # take付ける。規制されないように
    result_tweets.take(count)
  end
end
