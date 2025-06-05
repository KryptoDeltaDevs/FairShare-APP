# frozen_string_literal: true

require_relative 'group'

module FairShare
  # Behaviors of the currently logged in account
  class GroupMember
    attr_reader :id, :filename, :relative_path, :description, # basic info
                :content,
                :group # full details

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id             = attributes['id']
      @filename       = attributes['filename']
      @relative_path  = attributes['relative_path']
      @description    = attributes['description']
      @content        = attributes['content']
    end

    def process_included(included)
      @group = Group.new(included['group'])
    end
  end
end