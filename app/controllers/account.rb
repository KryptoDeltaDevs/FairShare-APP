# frozen_string_literal: true

require 'roda'
require_relative 'app'

module FairShare
  # Web controller for FairShare API
  class App < Roda
    route('account') do |routing|
      routing.on do
        # GET /account/login
        routing.get String do |email|
          if @current_account && @current_account['email'] == email
            view :account, locals: { current_account: @current_account }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
