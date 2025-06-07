# frozen_string_literal: true

require 'http'

module FairShare
  TABS = %w[expenses members payments].freeze

  # Web controller for FairShare API
  class App < Roda # rubocop:disable Metrics/ClassLength
    route('groups') do |routing|
      @path = 'groups'
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @groups_route = '/groups'

        routing.on 'create' do
          # GET /groups/[group_id]/create
          routing.get do
            group_list = GetAllGroups.new(App.config).call(@current_account)
            groups = Groups.new(group_list)
            ViewRenderer.new(self, content: 'pages/group_create', layouts: ['layouts/dashboard', 'layouts/root'],
                                   locals: { current_account: @current_account, groups: }).render
          end

          # POST /groups/[group_id]/create
          routing.post do
            group_data = Form::NewGroup.new.call(routing.params)

            if group_data.failure?
              flash[:error] = Form.message_values(group_data)
              routing.halt
            end

            CreateNewGroup.new(App.config).call(
              current_account: @current_account,
              group_data: group_data.to_h
            )

            flash[:notice] = 'Created new group'
          rescue StandardError => e
            puts "FAILURE Creating Group: #{e.inspect}"
            flash[:error] = 'Could not create a group'
          ensure
            routing.redirect @groups_route
          end
        end

        routing.on String do |group_id|
          @group_route = "#{@groups_route}/#{group_id}"

          routing.is 'edit' do
            # GET /groups/[group_id]/edit
            routing.get do
              group_info = GetGroup.new(App.config).call(@current_account, group_id)

              group = Group.new(group_info)

              ViewRenderer.new(self,
                               content: 'pages/group_edit',
                               layouts: ['layouts/dashboard', 'layouts/root'],
                               locals: { current_account: @current_account, group: group }).render
            end

            # POST /groups/[group_id]/edit
            routing.post do
              group_data = Form::NewGroup.new.call(routing.params)

              if group_data.failure?
                flash[:error] = Form.message_values(group_data)
                routing.halt
              end

              UpdateAGroup.new(App.config).call(
                current_account: @current_account,
                group_data: group_data.to_h,
                group_id:
              )

              flash[:notice] = 'Updated group information'
            rescue StandardError => e
              puts "FAILURE Updating Group: #{e.inspect}"
              flash[:error] = 'Could not update a group'
            ensure
              routing.redirect @group_route
            end
          end

          routing.is 'add_expense' do
            group_info = GetGroup.new(App.config).call(@current_account, group_id)

            group = Group.new(group_info)

            # GET /groups/[group_id]/add_expense
            routing.get do
              ViewRenderer.new(self,
                               content: 'pages/group_add_expense',
                               layouts: ['layouts/dashboard', 'layouts/root'],
                               locals: { current_account: @current_account, group: }).render
            end

            # POST /groups/[group_id]/add_expense
            routing.post do
              split_expense = SplitExpense.new.call(routing.params, group.members)
              expense = {
                payer_id: @current_account.id,
                total_amount: routing.params['total_amount'].to_f,
                name: routing.params['name'],
                description: routing.params['description']
              }
              AddExpense.new(App.config).call(@current_account, expense, split_expense, group_id)

              flash[:notice] = 'Created new expense'
              routing.redirect "#{@group_route}?tab=expenses"
            rescue SplitExpense::TotalError
              flash[:error] = 'Total percentage must equal 100%'
              routing.redirect "#{@group_route}/add_expense"
            end
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
          end

          routing.on 'add_member' do
            routing.is String do |token|
              # GET /groups/[group_id]/add_member/<token>
              routing.get do
                data = SecureMessage.new(token).decrypt

                AddMember.new(App.config).call(
                  current_account: @current_account,
                  target_email: data['target_email'],
                  group_id: group_id
                )

                routing.redirect '/groups'
              end
            end

            # POST /groups/[group_id]/add_member
            routing.post do
              target_account = routing.params
              SendInvitation.new(App.config).call(current_account: @current_account, group_id:,
                                                  target_email: target_account['email'])

              flash[:notice] = 'Invitation sent'
              routing.redirect "#{@group_route}?tab=members"
            end
          end

          routing.on 'pay' do
            routing.is do
              # POST /groups/[group_id]/pay
              routing.post do
                CreatePayment.new(App.config).call(
                  current_account: @current_account,
                  payment_data: routing.params,
                  group_id:
                )
                flash[:notice] = "You've paid the expense"
                routing.redirect "#{@group_route}?tab=expenses"
              end
            end
          end

          # GET /groups/[group_id]
          routing.is do
            current_tab = routing.params['tab']

            routing.redirect "#{@group_route}?tab=expenses" unless current_tab

            group_info = GetGroup.new(App.config).call(@current_account, group_id)

            group = Group.new(group_info)

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

        # GET /groups
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
