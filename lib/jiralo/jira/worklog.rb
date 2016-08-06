require "jiralo/jira"

class Jiralo::Jira::Worklog
  attr_accessor :author_key
  attr_accessor :author_email
  attr_accessor :comment
  attr_accessor :time_spent

  def initialize(json)
    author        = json["author"] || {}
    @author_key   = author["key"].to_s
    @author_email = author["emailAddress"].to_s
    @comment      = json["comment"].to_s
    @time_spent   = json["timeSpentSeconds"].to_i
  end

  def for_user?(user_or_email)
    author_key.casecmp(user_or_email) || author_email.casecmp(user_or_email)
  end
end
