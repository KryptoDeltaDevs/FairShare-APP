# frozen_string_literal: true

require 'http'

module FairShare
  # Returns all groups belonging to an account
  class GetGroup
    def initialize(config)
      @config = config
    end

    def call(current_account, group_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .get("#{@config.API_URL}/groups/#{group_id}")

      response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
    end
  end
end