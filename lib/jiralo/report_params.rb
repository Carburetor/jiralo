require "ostruct"

module Jiralo
  class ReportParams
    attr_accessor :project
    attr_accessor :user
    attr_accessor :from
    attr_accessor :to

    def initialize(project:, user:, from:, to:)
      @project = project.to_s
      @user    = user.to_s
      @from    = from
      @to      = to
    end
  end
end
