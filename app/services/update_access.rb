# frozen_string_literal: true

require 'http'

module FairShare
  class UpdateAccess
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, group_members:, group_id:)
      config_url = "#{api_url}/groups/#{group_id}/members"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .put(config_url, json: group_members)

      response.code == 200 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
