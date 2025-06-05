# frozen_string_literal: true

require 'http'

module FairShare
  # Returns all groups belonging to an account
  class GetAllGroups
    def initialize(config)
      @config = config
    end

    def call(current_account)
      response = HTTP.auth("Bearer #{current_account.auth_token}").get("#{@config.API_URL}/groups")

      response.code == 200 ? JSON.parse(response.to_s) : nil
    end
  end
end
