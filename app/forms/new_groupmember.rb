# frozen_string_literal: true

require_relative 'form_base'

module FairShare
  module Form
    class NewGroupMember < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_groupmember.yml')

      params do
        required(:filename).filled(max_size?: 256, format?: FILENAME_REGEX)
        required(:relative_path).maybe(format?: PATH_REGEX)
        required(:description).maybe(:string)
        required(:content).filled(:string)
      end
    end
  end
end