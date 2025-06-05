# frozen_string_literal: true

require 'ostruct'

module FairShare
  # Behaviors of the currently logged in account
  class Group
    attr_reader :id, :name, :description, :owner, :members, :expenses, :expense_splits, :payments, :policies

    def initialize(group_info)
      process_attributes(group_info['attributes'])
      process_relationships(group_info['relationships'])
      process_policies(group_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @name = attributes['name']
      @description = attributes['description']
    end

    def process_relationships(relationships)
      return nil unless relationships

      @owner = Account.new(relationships['owner'])
      @members = process_members(relationships['members'])
      @expenses = process_expenses(relationships['expenses'])
      @expense_splits = process_expense_splits(relationships['expense_splits'])
      @payments = process_payments(relationships['payments'])
    end

    def process_members(members)
      return nil unless members

      members.map { |member| Account.new(member) }
    end

    def process_expenses(expenses)
      return nil unless expenses

      expenses.map { |expense| Expense.new(expense) }
    end

    def process_expense_splits(expense_splits)
      return nil unless expense_splits

      expense_splits.map { |expense_split| ExpenseSplit.new(expense_split) }
    end

    def process_payments(payments)
      return nil unless payments

      payments.map { |payment| Payment.new(payment) }
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end
  end
end
