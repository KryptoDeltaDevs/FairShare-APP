# frozen_string_literal: true

require 'roda'
require_relative 'app'

module FairShare
  # Web controller for FairShare API
  class App < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          account = AuthenticateAccount.new(App.config).call(
            email: routing.params['email'],
            password: routing.params['password']
          )

          SecureSession.new(session).set(:current_account, account)
          flash[:notice] = "Welcome back #{account['name']}!"
          routing.redirect '/'
        rescue AuthenticateAccount::UnauthorizedError
          flash.now[:error] = 'Email and password did not match our records'
          response.status = 400
          view :login
        rescue AuthenticateAccount::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      @logout_route = '/auth/logout'
      routing.on 'logout' do
        routing.get do
          SecureSession.new(session).delete(:current_account)
          flash[:notice] = "You've been logged out"
          routing.redirect @login_route
        end
      end
    end
  end
end
