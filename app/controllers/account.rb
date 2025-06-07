# frozen_string_literal: true

require 'roda'
require_relative 'app'

module FairShare
  # Web controller for FairShare API
  class App < Roda
    route('account') do |routing|
      @path = 'account'
      routing.on do
        # GET /account/[id]
        routing.get String do |id|
          routing.redirect '/auth/login' unless @current_account.logged_in?
          account = GetAccountDetails.new(App.config).call(@current_account, id)

          ViewRenderer.new(self,
                           content: 'pages/account',
                           layouts: ['layouts/dashboard', 'layouts/root'],
                           locals: { current_account: account }).render
        end

        # POST /account/<registration_token>
        routing.post String do |registration_token|
          passwords = Form::Passwords.new.call(routing.params)
          raise Form.message_values(passwords) if passwords.failure?

          new_account = SecureMessage.new(registration_token).decrypt
          CreateAccount.new(App.config).call(
            name: routing.params['name'],
            email: new_account['email'],
            password: passwords['password']
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
