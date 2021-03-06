require 'rubygems'
require 'yaml'
require 'twitter'

class App

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end

    @wait_time = 10 * 60

    @hashtags = '#daz3dart #3drenderbot #3dmodeling #3danimation #3drendering'
  end

  def run
    while true
      begin
      puts "Begin routine at #{DateTime.now}"
      @hashtags.split(' ').each do |hashtag|
        puts "Retweeting #{hashtag}"
        @client.search("#{hashtag} -rt", lang: "en").take(5).each do |object|
          try_retweet(object)
        end
      end

      # Mentions
      @client.mentions_timeline.take(5).each do |mention|
        try_retweet(mention)
      end

      sleep(@wait_time)
      rescue Twitter::Error::TooManyRequests
        puts "I have mad too many requests to twitter. I will sleep for some time"
        sleep(@wait_time * 4)
      end
    end
  end

  def try_retweet(object)
    begin
      case object
        when Twitter::Tweet
          @client.retweet object unless @client.retweets(object.id, options = {}).count > 0
      end
    rescue Twitter::Error::Forbidden
      $stderr.print "Something has failed " + $!
    end
  end
end


app = App.new
app.run