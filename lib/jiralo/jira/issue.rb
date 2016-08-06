require "jiralo/jira"

class Jiralo::Jira::Issue
  attr_accessor :key
  attr_accessor :summary
  attr_accessor :parent

  def initialize(json)
    fields   = json["fields"] || {}
    @key     = json["key"].to_s
    @summary = fields["summary"].to_s
    @parent  = Issue.new(fields["parent"]) if fields["parent"]
  end
end
