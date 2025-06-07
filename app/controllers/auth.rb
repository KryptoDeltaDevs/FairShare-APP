# frozen_string_literal: true

require 'roda'
require_relative 'app'

module FairShare
  # Web controller for FairShare API
  class App < Roda
    route('auth') do |routing|
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          ViewRenderer.new(self, content: 'pages/login', layouts: ['layouts/auth', 'layouts/root']).render
        end

        # POST /auth/login
        routing.post do
          credentials = Form::LoginCredentials.new.call(routing.params)

          if credentials.failure?
            flash[:error] = 'Please enter both email and password'
            routing.redirect @login_route
          end

          authenticated = AuthenticateAccount.new(App.config).call(**credentials.values)
          current_account = Account.new(authenticated[:account], authenticated[:auth_token])
          CurrentSession.new(session).current_account = current_account
          flash[:notice] = "Welcome back #{current_account.name}!"
          routing.redirect '/dashboard'
        rescue AuthenticateAccount::UnauthorizedError
          flash.now[:error] = 'Email and password did not match our records'
          response.status = 401
          ViewRenderer.new(self, content: 'pages/login', layouts: ['layouts/auth', 'layouts/root']).render
        rescue AuthenticateAccount::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do
        routing.is do
          # GET /auth/register
          routing.get do
            ViewRenderer.new(self, content: 'pages/register', layouts: ['layouts/auth', 'layouts/root']).render
          end

          # POST /auth/register
          routing.post do
            registration = Form::Registration.new.call(routing.params)

            if registration.failure?
              flash[:error] = Form.validation_errors(registration)
              routing.redirect @register_route
            end

            VerifyRegistration.new(App.config).call(registration)

            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect @register_route
          rescue VerifyRegistration::ApiServerError => e
            App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Our servers are not responding -- please try later'
            routing.redirect @register_route
          rescue StandardError => e
            App.logger.warn "Could not process registration: #{e.inspect}"
            flash[:error] = 'Registration process failed -- please contact us'
            routing.redirect @register_route
          end
        end

        # GET /auth/register/<token>
        routing.get String do |registration_token|
          flash.now[:notice] = 'Email verified! Please create a name and password'
          new_account = SecureMessage.new(registration_token).decrypt
          ViewRenderer.new(self, content: 'pages/register_confirm', layouts: ['layouts/auth', 'layouts/root'],
                                 locals: { new_account:, registration_token: }).render
        end
      end

      # GET /auth/

      @logout_route = '/auth/logout'
      routing.is 'logout' do
        # GET /auth/logout
        routing.get do
          CurrentSession.new(session).delete
          flash[:notice] = "You've been logged out"
          routing.redirect @login_route
        end
      end
    end
  end
end
