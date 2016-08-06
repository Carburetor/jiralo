require "jiralo/jira"
require "jiralo/jira/issue"
require "json"
require "active_support/core_ext/string/filters"

module Jiralo
  class Report
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def write(path)
    end

    def worklogs
      issues
        .lazy
        .flat_map { |issue| issue.worklogs_for_user(params.user) }
        .sort     { |worklog, other| worklog.started_at <=> other.started_at }
    end

    def issues
      json = JSON.parse(download_issues.to_s)
      json["issues"].map do |issue|
        Jira::Issue.new(issue)
      end
    end

    private

    def download_issues
      Jira
        .http_authenticated
        .get(
          "https://carburetor.atlassian.net/rest/api/#{ api_version }/search",
          params: {
            "startIndex" => "0",
            "fields"     => "id,key,parent,summary",
            "maxResults" => "1000",
            "jql"        => jql_query
          }
        )
    end

    def jql_query
      str = <<-EOS
        updated >= #{ params.from } and
        updated <= #{ params.to } and
        timespent > 0
      EOS
      str.squish
    end

    def api_version
      Jira.api_version
    end
  end
end
