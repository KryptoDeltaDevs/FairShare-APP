# frozen_string_literal: true

require_relative 'form_base'

module FairShare
  module Form
    class NewExpense < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_expense.yml')

      params do
        required(:name).filled
        optional(:description)
        required(:total_amount).filled
      end
    end
  end
end
