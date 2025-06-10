# frozen_string_literal: true

require_relative 'form_base'

module FairShare
  module Form
    class AddMember < Dry::Validation::Contract
      params do
        required(:email).filled(format?: EMAIL_REGEX)
      end
    end
  end
end
