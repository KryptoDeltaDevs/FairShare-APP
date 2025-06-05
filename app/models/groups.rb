# frozen_string_literal: true

require_relative 'group'

module FairShare
  # Behaviors of the currently logged in account
  class Groups
    attr_reader :all

    def initialize(group_list)
      @all = group_list.map do |group|
        Group.new(group)
      end
    end
  end
end
