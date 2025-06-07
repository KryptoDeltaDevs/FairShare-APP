# frozen_string_literal: true

require 'http'

module FairShare
  # Create a new configuration file for a group
  class UpdateAGroup
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, group_data:, group_id:)
      config_url = "#{api_url}/groups/#{group_id}"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .put(config_url, json: group_data)

      response.code == 200 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
