# frozen_string_literal: true

require 'http'

module FairShare
  # Create a new configuration file for a group
  class CreateNewGroupMember
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, group_id:, group_member_data:)
      config_url = "#{api_url}/groups/#{group_id}/group_member"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .post(config_url, json: group_member_data)

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end