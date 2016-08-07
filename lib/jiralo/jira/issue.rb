require "jiralo/jira"
require "jiralo/jira/worklog"
require "json"
require "active_support/core_ext/object/blank"
require "thread/future"

class Jiralo::Jira::Issue
  attr_accessor :id
  attr_accessor :key
  attr_accessor :summary
  attr_accessor :parent

  def initialize(json)
    fields   = json["fields"] || {}
    @id      = json["id"].to_s
    @key     = json["key"].to_s
    @summary = fields["summary"].to_s
    @parent  = self.class.new(fields["parent"]) if fields["parent"]
  end

  def worklogs_for_user(user_or_email)
    return [] if user_or_email.to_s.blank?

    worklogs.select { |worklog| worklog.for_user?(user_or_email.to_s) }
  end

  def worklogs
    json = JSON.parse(download_worklogs.to_s)
    logs = json["fields"]   || {}
    logs = logs["worklog"]  || {}
    logs = logs["worklogs"] || []

    logs.map do |worklog|
      ::Jiralo::Jira::Worklog.new(self, worklog)
    end
  end

  private

  def issue_url
    "#{ base_url }/rest/api/#{ api_version }/issue/#{ id }"
  end

  def download_worklogs
    ::Jiralo::Jira
      .http_authenticated
      .get(
        issue_url,
        params: {
          "fields" => "worklog,components",
        }
      )
  end

  def api_version
    ::Jiralo::Jira.api_version
  end

  def base_url
    ::Jiralo::Jira.base_url
  end
end
