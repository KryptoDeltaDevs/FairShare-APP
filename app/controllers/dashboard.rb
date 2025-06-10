# frozen_string_literal: true

require_relative 'app'

module FairShare
  # Route for dashboard
  class App < Roda
    route('dashboard') do |routing|
      @path = 'dashboard'
      routing.is do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        owe = GetOwed.new(App.config).call(@current_account)

        ViewRenderer.new(self, content: 'pages/dashboard', layouts: ['layouts/dashboard', 'layouts/root'],
                               locals: { owe: }).render
      end
    end
  end
end
