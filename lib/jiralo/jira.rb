require "http"

module Jiralo
  module Jira
    module_function

    def api_version
      2
    end

    def http_authenticated
      HTTP
        .basic_auth(user: ENV["JIRA_USERNAME"], pass: ENV["JIRA_PASSWORD"])
        .headers(accept: "application/json")
    end

    def base_url
      ENV["JIRA_URL"] ||= "https://carburetor.atlassian.net"
    end
  end
end
