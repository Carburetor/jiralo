# https://carburetor.atlassian.net/rest/api/2/search?startIndex=0&jql=created+%3C+2016-08-06+and+updated+%3E+2016-08-01+and+timespent+%3E+0&fields=id,key,parent,summary&maxResults=1000
# https://carburetor.atlassian.net/rest/api/2/issue/19180?fields=worklog,components
require "jiralo/jira"
require "jiralo/jira/issue"
require "json"
require "active_support/core_ext/string/filters"
require "csv"
require "active_support/core_ext/date/calculations"
require "thread/future"

module Jiralo
  class Report
    COLUMNS = [
      "Started At",
      "Ticket",
      "Title",
      "Time spent",
      "Log description",
      "Ticket details"
    ].freeze

    attr_reader :params

    def initialize(params)
      @params = params
    end

    def write(path)
      CSV.open(path.to_s, "wb") do |csv|
        csv << COLUMNS
        worklogs.each { |worklog| csv << worklog.to_csv }
      end
    end

    def worklogs
      issues
        .map { |issue| Thread.future { worklogs_for(issue) } }
        .lazy
        .flat_map { |log| ~log }
        .reject   { |log| log.started_at.beginning_of_day < params.from }
        .reject   { |log| log.started_at.end_of_day > params.to }
        .sort     { |log, other| log.started_at <=> other.started_at }
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
          "#{ base_url }/rest/api/#{ api_version }/search",
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
        timespent > 0
      EOS
      str.squish
    end

    def worklogs_for(issue)
      issue.worklogs_for_user(params.user.to_s)
    end

    def api_version
      Jira.api_version
    end

    def base_url
      Jira.base_url
    end
  end
end
