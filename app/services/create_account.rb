# frozen_string_literal: true

require 'http'

module FairShare
  # Returns an authenticated user, or nil
  class CreateAccount
    class InvalidAccount < StandardError; end

    def initialize(config)
      @config = config
    end

    def call(name:, email:, password:)
      account = { name:, email:, password: }

      response = HTTP.post(
        "#{@config.API_URL}/accounts/",
        json: SignedMessage.sign(account)
      )

      raise InvalidAccount unless response.code == 201
    end
  end
end
