# frozen_string_literal: true

require_relative 'form_base'

module FairShare
  module Form
    class NewGroup < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_group.yml')

      params do
        required(:name).filled
        required(:description).filled
      end
    end
  end
end
