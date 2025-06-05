# frozen_string_literal: true

require_relative 'account'
require_relative 'group'

module FairShare
  class Expense
    attr_reader :id, :name, :description, :payer_id, :total_amount, :created_at, :group, :payer

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @name = attributes['name']
      @description = attributes['description']
      @payer_id = attributes['payer_id']
      @total_amount = attributes['total_amount']
      @created_at = attributes['created_at']
    end

    def process_included(included)
      @group = Group.new(included['group'])
      @payer = Account.new(included['payer'])
    end
  end
end
