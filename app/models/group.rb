# frozen_string_literal: true

require 'ostruct'

module FairShare
  # Behaviors of the currently logged in account
  class Group
    attr_reader :id, :name, :repo_url, # basic info
                :owner, :members, :group_member, :policies # full details

    def initialize(group_info)
      process_attributes(group_info['attributes'])
      process_relationships(group_info['relationships'])
      process_policies(group_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @name = attributes['name']
      @repo_url = attributes['repo_url']
    end

    def process_relationships(relationships)
      return unless relationships

      @admin = Account.new(relationships['admin'])
      @members = process_members(relationships['members'])
      @group_member = process_group_member(relationships['group_member'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end

    def process_group_member(group_member_info)
      return nil unless group_member_info

      group_member_info.map { |group_member_info| GroupMember.new(group_member_info) }
    end

    def process_members(members)
      return nil unless members

      members.map { |account_info| Account.new(account_info) }
    end
  end
end