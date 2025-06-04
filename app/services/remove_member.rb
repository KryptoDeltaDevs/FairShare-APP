# frozen_string_literal: true

module FairShare
    # Service to add member to group
    class RemoveMember
      class MemberNotRemoved < StandardError; end
  
      def initialize(config)
        @config = config
      end
  
      def api_url
        @config.API_URL
      end
  
      def call(current_account:, member:, group_id:)
        response = HTTP.auth("Bearer #{current_account.auth_token}")
                      .delete("#{api_url}/groups/#{group_id}/members",
                              json: { email: member[:email] })
  
        raise MemberrNotRemoved unless response.code == 200
      end
    end
  end