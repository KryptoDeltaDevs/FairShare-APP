# frozen_string_literal: true

require 'http'

module FairShare
  class GetOwed
    def initialize(config)
      @config = config
    end

    def call(current_account)
      response = HTTP.auth("Bearer #{current_account.auth_token}").get("#{@config.API_URL}/expenses")
      response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
    end
  end
end
