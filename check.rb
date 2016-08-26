# frozen_string_literal: true
$LOAD_PATH << './'
require 'getter'
require 'json'
require 'pp'

def configure_api_status
  api_key = ENV['TWITTER_API_KEY']
  api_secret = ENV['TWITTER_API_SECRET']
  TweetsGetter.new(api_key, api_secret)
end

tweets_getter = configure_api_status
# pp JSON.parse(tweets_getter.get_tweets(q: 'こんにちは'))
pp tweets_getter.get_tweets(q: 'to:@Nintendo', options: { lang: 'ja', result_type: 'recent' })
