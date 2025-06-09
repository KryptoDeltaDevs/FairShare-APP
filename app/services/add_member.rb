# frozen_string_literal: true

module FairShare
  # Service to add member to group
  class AddMember
    class MemberNotAdded < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, target_email:, group_id:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post("#{api_url}/groups/#{group_id}/members",
                           json: { email: target_email })

      raise MemberNotAdded unless response.code == 201
    end
  end
end
