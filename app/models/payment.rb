# frozen_string_literal: true

require_relative 'account'
require_relative 'group'

module FairShare
  class Payment
    attr_reader :id, :expense_id, :amount, :created_at, :group, :expense, :from_account, :to_account

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @expense_id = attributes['expense_id']
      @amount = attributes['amount']
      @created_at = attributes['created_at']
    end

    def process_included(included)
      @group = Group.new(included['group'])
      @expense = Expense.new(included['expense'])
      @from_account = Account.new(included['from_account'])
      @to_account = Account.new(included['to_account'])
    end
  end
end
