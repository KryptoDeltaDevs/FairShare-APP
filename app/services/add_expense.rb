# frozen_string_literal: true

module FairShare
  class AddExpense
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account, expense, split_expense, group_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post("#{api_url}/groups/#{group_id}/expenses",
                           json: { expense:, split_expense: })

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
