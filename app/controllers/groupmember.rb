# frozen_string_literal: true

require 'roda'

module FairShare
  # Web controller for FairShare API
  class App < Roda
    route('group_member') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?

      # GET /group_member/[group_member_id]
      routing.get(String) do |group_member_id|
        group_member_info = GetGroupMember.new(App.config)
                              .call(@current_account, group_member_id)
        group_member = GroupMember.new(group_member_info)

        view :group_member, locals: {
          current_account: @current_account, group_member: group_member
        }
      end
    end
  end
end