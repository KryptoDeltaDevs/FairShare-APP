# frozen_string_literal: true

require_relative 'group'

module FairShare
  # Behaviors of the currently logged in account
  class Groups
    attr_reader :all

    def initialize(groups_list)
      @all = groups_list.map do |group|
        Group.new(group)
      end
    end
  end
end