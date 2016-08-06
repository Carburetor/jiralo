require "jiralo/jira"
require "json"

class Jiralo::Jira::Issue
  attr_accessor :key
  attr_accessor :summary
  attr_accessor :parent

  def initialize(json)
    fields   = json["fields"] || {}
    @id      = json["id"].to_s
    @key     = json["key"].to_s
    @summary = fields["summary"].to_s
    @parent  = Issue.new(fields["parent"]) if fields["parent"]
  end

  def worklogs
    json = JSON.parse(download_worklogs.to_s)
    json["worklog"].map do |worklog|
      Worklog.new(worklog)
    end
  end

  private

  def issue_url
    "https://carburetor.atlassian.net/rest/api/#{ api_version }/issue/#{ id }"
  end

  def download_worklogs
    Jira
      .http_authenticated
      .get(
        issue_url,
        params: {
          "fields" => "worklog,components",
        }
      )
  end

  def api_version
    Jira.api_version
  end
end
