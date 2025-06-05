# frozen_string_literal: true

require 'http'

module FairShare
  TABS = %w[expenses members payments].freeze

  # Web controller for FairShare API
  class App < Roda
    route('groups') do |routing|
      @path = 'groups'
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @groups_route = '/groups'

        routing.on 'create' do
          routing.get do
            group_list = GetAllGroups.new(App.config).call(@current_account)
            groups = Groups.new(group_list)
            ViewRenderer.new(self, content: 'pages/group_create', layouts: ['layouts/dashboard', 'layouts/root'],
                                   locals: { current_account: @current_account, groups: }).render
          end

          routing.post do
          end
        end

        routing.on String do |group_id|
          @group_route = "#{@groups_route}/#{group_id}"

          routing.on 'edit' do
          end

          # GET /groups/[group_id]
          routing.is do
            current_tab = routing.params['tab']

            routing.redirect "#{@group_route}?tab=expenses" unless current_tab

            group_info = GetGroup.new(App.config).call(@current_account, group_id)

            group = Group.new(group_info)

            # puts "Group: #{group.inspect}"

            tabs = TABS.dup
            tabs << 'settings' if group.policies.can_edit
            routing.redirect "#{@group_route}?tab=expenses" unless tabs.include?(current_tab)

            ViewRenderer.new(self,
                             content: 'pages/group',
                             layouts: ['layouts/dashboard', 'layouts/root'],
                             locals: { current_account: @current_account, group: group, current_tab:,
                                       tabs: }).render
          rescue StandardError => e
            puts "#{e.inspect}\n\n#{e.backtrace}"
            flash[:error] = 'Group not found'
            routing.redirect @groups_route
          end
        end

        routing.get do
          group_list = GetAllGroups.new(App.config).call(@current_account)
          groups = Groups.new(group_list)
          ViewRenderer.new(self, content: 'pages/groups', layouts: ['layouts/dashboard', 'layouts/root'],
                                 locals: { current_account: @current_account, groups: }).render
        end
      end
    end
  end
end
