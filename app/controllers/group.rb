# frozen_string_literal: true

require 'roda'

module FairShare
  # Web controller for FairShare API
  class App < Roda
    route('groups') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @groups_route = '/groups'

        routing.on(String) do |group_id|
          @groups_route = "#{@groups_route}/#{group_id}"

          # GET /groups/[group_id]
          routing.get do
            group_info = GetGroup.new(App.config).call(
              @current_account, group_id
            )
            group = Group.new(group_info)

            view :group, locals: {
              current_account: @current_account, group: group
            }
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Group not found'
            routing.redirect @groups_route
          end

          # POST /groups/[group_id]/members
          routing.post('members') do
            action = routing.params['action']
            member_info = Form::MemberEmail.new.call(routing.params)
            if member_info.failure?
              flash[:error] = Form.validation_errors(member_info)
              routing.halt
            end

            task_list = {
              'add' => { service: AddMember,
                         message: 'Added new member to group' },
              'remove' => { service: RemoveMember,
                            message: 'Removed member from group' }
            }

            task = task_list[action]
            task[:service].new(App.config).call(
              current_account: @current_account,
              member: member_info,
              group_id: group_id
            )
            flash[:notice] = task[:message]

          rescue StandardError
            flash[:error] = 'Could not find member'
          ensure
            routing.redirect @group_route
          end

          # POST /groups/[group_id]/group_member/
          routing.post('group_member') do
            group_member_data = Form::NewGroupMember.new.call(routing.params)
            if group_member_data.failure?
              flash[:error] = Form.message_values(group_member_data)
              routing.halt
            end

            CreateNewGroupMember.new(App.config).call(
              current_account: @current_account,
              group_id: group_id,
              group_member_data: group_member_data.to_h
            )

            flash[:notice] = 'Your group_member was added'
          rescue StandardError => error
            puts error.inspect
            puts error.backtrace
            flash[:error] = 'Could not add group_member'
          ensure
            routing.redirect @group_route
          end
        end

        # GET /groups/
        routing.get do
          group_list = GetAllGroups.new(App.config).call(@current_account)

          groups = Groups.new(group_list)

          view :groups_all, locals: {
            current_account: @current_account, groups: groups
          }
        end

        # POST /groups/
        routing.post do
          routing.redirect '/auth/login' unless @current_account.logged_in?
          puts "GROUP: #{routing.params}"
          group_data = Form::NewGroup.new.call(routing.params)
          if group_data.failure?
            flash[:error] = Form.message_values(group_data)
            routing.halt
          end

          CreateNewGroup.new(App.config).call(
            current_account: @current_account,
            group_data: group_data.to_h
          )

          flash[:notice] = 'Add group_members and members to your new group'
        rescue StandardError => e
          puts "FAILURE Creating Group: #{e.inspect}"
          flash[:error] = 'Could not create group'
        ensure
          routing.redirect @groups_route
        end
      end
    end
  end
end