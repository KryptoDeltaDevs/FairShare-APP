# frozen_string_literal: true

class SplitExpense
  class TotalError < StandardError; end

  def initialize(total_percentage = 0.0, member_percentage = [])
    @total_percentage = total_percentage
    @member_percentage = member_percentage
  end

  def call(routing, members)
    members.each do |member|
      key = "member_#{member.id}"
      percentage_str = routing[key]
      percentage = percentage_str.to_f

      @total_percentage += percentage
      percentage /= 100
      @member_percentage << { member: member.id, percentage: }
    end

    raise TotalError if @total_percentage.to_i != 100

    @member_percentage
  end
end
