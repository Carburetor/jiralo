require "jiralo/jira"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
require "jiralo/time_spent_humanizer"

class Jiralo::Jira::Worklog
  attr_accessor :issue
  attr_accessor :author_key
  attr_accessor :author_email
  attr_accessor :comment
  attr_accessor :time_spent
  attr_accessor :started_at

  delegate :summary, to: :root_issue,  prefix: true
  delegate :key,     to: :root_issue,  prefix: true
  delegate :summary, to: :child_issue, prefix: true, allow_nil: true

  def initialize(issue, json)
    author        = json["author"] || {}
    @issue        = issue
    @author_key   = author["key"].to_s
    @author_email = author["emailAddress"].to_s
    @comment      = json["comment"].to_s
    @time_spent   = json["timeSpentSeconds"].to_i
    @started_at   = DateTime.parse(json["started"])
  end

  def for_user?(user_or_email)
    author_key.casecmp(user_or_email)   == 0 ||
    author_email.casecmp(user_or_email) == 0
  end

  def to_csv
    [
      started_at.to_s,
      root_issue_key,
      root_issue_summary,
      time_spent_humanized,
      comment,
      child_issue_summary.to_s
    ]
  end

  def author
    return author_email.to_s if author_key.to_s.blank?
    author_key.to_s
  end

  def root_issue
    issue.parent || issue
  end

  def child_issue
    return issue if issue.parent
    nil
  end

  def time_spent_humanized
    ::Jiralo::TimeSpentHumanizer.humanize(time_spent)
  end
end
