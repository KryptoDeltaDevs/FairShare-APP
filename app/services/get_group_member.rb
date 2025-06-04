# frozen_string_literal: true

require 'http'

module FairShare
  # Returns all groups belonging to an account
  class GetGroupMember
    def initialize(config)
      @config = config
    end

    def call(user, group_member_id)
      response = HTTP.auth("Bearer #{user.auth_token}")
                    .get("#{@config.API_URL}/group_member/#{group_member_id}")

      response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
    end
  end
end