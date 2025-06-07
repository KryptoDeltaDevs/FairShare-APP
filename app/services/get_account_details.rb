# frozen_string_literal: true

require 'http'

class GetAccountDetails
  class InvalidAccount < StandardError
    def message
      'You are not authorized to see details of that account'
    end
  end

  def initialize(config)
    @config = config
  end

  def call(current_account, id)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/accounts/#{id}")

    raise InvalidAccount if response.code != 200

    data = JSON.parse(response)['data']['attributes']
    account_details = data['account']
    auth_token = data['auth_token']
    FairShare::Account.new(account_details, auth_token)
  end
end
