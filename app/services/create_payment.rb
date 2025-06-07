# frozen_string_literal: true

require 'http'

module FairShare
  # Create a new configuration file for a group
  class CreatePayment
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, payment_data:, group_id:)
      config_url = "#{api_url}/groups/#{group_id}/payments"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post(config_url, json: payment_data)

      response.code == 202 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
