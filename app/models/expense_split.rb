# frozen_string_literal: true

require_relative 'account'
require_relative 'expense'

module FairShare
  class ExpenseSplit
    attr_reader :expense_id, :account_id, :amount_owed, :created_at

    def initialize(info)
      process_attributes(info['attributes'])
    end

    private

    def process_attributes(attributes)
      @expense_id = attributes['expense_id']
      @account_id = attributes['account_id']
      @amount_owed = attributes['amount_owed']
      @created_at = attributes['created_at']
    end
  end
end
