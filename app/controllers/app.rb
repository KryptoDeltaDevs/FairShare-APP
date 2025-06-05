# frozen_string_literal: true

require 'roda'

module FairShare
  # Base class for FairShare Web Application
  class App < Roda
    plugin :render, engine: 'erb', views: 'app/presentation/views'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :public, root: 'app/presentation/public'
    plugin :multi_route
    plugin :flash

    route do |routing|
      response['Content-Type'] = 'text/html; charset=utf-8'
      @current_account = CurrentSession.new(session).current_account

      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        routing.redirect '/dashboard' if @current_account.logged_in?
        # view('pages/home', layout: false, locals: { current_account: @current_account })
        routing.redirect '/auth/login'
      end
    end
  end
end
