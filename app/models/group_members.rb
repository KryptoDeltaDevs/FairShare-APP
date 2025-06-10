# frozen_string_literal: true

require_relative 'account'
require_relative 'group'

module FairShare
  class GroupMember
    attr_reader :group_id, :account_id, :role, :can_add_expense

    def initialize(info)
      process_attributes(info['attributes'])
    end

    def to_h
      {
        group_id:,
        account_id:,
        role:,
        can_add_expense:
      }
    end

    private

    def process_attributes(attributes)
      @group_id = attributes['group_id']
      @account_id = attributes['account_id']
      @role = attributes['role']
      @can_add_expense = attributes['can_add_expense']
    end
  end
end
