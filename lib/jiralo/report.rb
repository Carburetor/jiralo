require "jiralo/jira"
require "json"

module Jiralo
  class Report
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def write(path)
    end

    private

    def issues
      json = JSON.parse(download_issues.to_s)
      json["issues"].map do |issue|
        Jira::Issue.new(issue)
      end
    end

    def download_issues
      Jira
        .http_authenticated
        .get(
          "https://carburetor.atlassian.net/rest/api/#{ api_version }/search",
          params: {
            "startIndex" => "0",
            "fields"     => "key,parent,summary",
            "maxResults" => "1000",
            "jql"        => jql_query
          }
        )
    end

    def jql_query
      "updated>=#{ params.from } and "\
      "updated<=#{ params.to } and "\
      "timespent>0"
    end

    def api_version
      Jira.api_version
    end
  end
end
