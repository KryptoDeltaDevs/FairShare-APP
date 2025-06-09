# frozen_string_literal: true

require_relative 'form_base'

module FairShare
  module Form
    class LoginCredentials < Dry::Validation::Contract
      params do
        required(:email).filled
        required(:password).filled
      end
    end

    class Registration < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/account_details.yml')

      params do
        required(:email).filled(format?: EMAIL_REGEX)
      end
    end

    class Passwords < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/password.yml')

      params do
        required(:password).filled
        required(:password_confirm).filled
      end

      def enough_entropy?(string)
        StringSecurity.entropy(string) >= 3.0
      end

      rule(:password) do
        key.failure('Password must be more complex') unless enough_entropy?(value)
      end

      rule(:password, :password_confirm) do
        key.failure('Password do not match') unless values[:password].eql?(values[:password_confirm])
      end
    end
  end
end
