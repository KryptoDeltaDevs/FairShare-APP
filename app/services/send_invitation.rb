# frozen_string_literal: true

require 'http'

module FairShare
  class SendInvitation
    def initialize(config)
      @config = config
    end

    def call(current_account:, group_id:, target_email:)
      data = { target_email: }
      token = SecureMessage.encrypt(data)
      data['invitation_url'] = "#{@config.APP_URL}/groups/#{group_id}/add_member/#{token}"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post("#{@config.API_URL}/groups/#{group_id}/send_invitation", json: data)

      JSON.parse(response.to_s)
    end
  end
end
