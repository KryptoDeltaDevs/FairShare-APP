# frozen_string_literal: true

require 'roda'
require_relative 'app'

module FairShare
  # Web controller for FairShare API
  class App < Roda
    route('account') do |routing|
      routing.on do
        # GET /account/id
        routing.get String do |id|
          if @current_account && @current_account.id == id
            view :account, locals: { current_account: @current_account }
          else
            routing.redirect '/auth/login'
          end
        end

        # POST /account/<registration_token>
        routing.post String do |registration_token|
          raise 'Passwords do not match or empty' if
            routing.params['password'].empty? ||
            routing.params['password'] != routing.params['password_confirm']

          new_account = SecureMessage.new(registration_token).decrypt
          CreateAccount.new(App.config).call(
            name: routing.params['name'],
            email: new_account['email'],
            password: routing.params['password']
          )
          flash[:notice] = 'Account created! Please login'
          routing.redirect '/auth/login'
        rescue CreateAccount::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/register'
        rescue StandardError => e
          flash[:error] = e.message
          routing.redirect("#{App.config.APP_URL}/auth/register/#{registration_token}")
        end
      end
    end
  end
end
