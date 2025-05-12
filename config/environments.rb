# frozen_string_literal: true

require 'delegate'
require 'roda'
require 'figaro'
require 'logger'
require 'rack/ssl-enforcer'
require 'rack/session'
require 'rack/session/redis'
require_relative '../require_app'

require_app('lib')

module FairShare
  # Configuration for the API
  class App < Roda
    plugin :environments

    Figaro.application = Figaro::Application.new(
      environment:,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config = Figaro.env

    # HTTP Request logging
    configure :development, :production do
      plugin :common_logger, $stdout
    end

    # Custom events logging
    LOGGER = Logger.new($stderr)
    def self.logger = LOGGER

    # Session configuration
    ONE_WEEK = 7 * 24 * 60 * 60
    @redis_url = ENV.delete('REDISCLOUD_URL')
    SecureMessage.setup(ENV.delete('MSG_KEY'))
    SecureSession.setup(@redis_url)

    configure :development, :test do
      logger.level = Logger::ERROR

      # use Rack::Session::Cookie, expire_after: ONE_WEEK, secret: config.SESSION_SECRET

      use Rack::Session::Pool, expire_after: ONE_WEEK

      # use Rack::Session::Redis, expire_after: ONE_WEEK, redis_server: @redis_url

      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/test_load_all'
      end
    end

    configure :production do
      use Rack::SslEnforcer, hsts: true

      use Rack::Session::Redis, expire_after: ONE_WEEK, redis_server: @redis_url
    end
  end
end
