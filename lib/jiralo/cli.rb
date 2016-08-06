require "optparse"
require "jiralo/report_params"
require "jiralo/report"
require "pathname"
require "fileutils"
require "active_support/core_ext/date/calculations"

module Jiralo
  class CLI
    PARAM_KEYS = [:project, :user, :from, :to].freeze

    attr_accessor :options
    attr_accessor :params

    def initialize(args)
      @options = {}
      @params  = {}
      parse_options(args)
    end

    def run
      report = Report.new(ReportParams.new(**params))
      report.write(file_path.to_s)
    end

    def help
      puts options
      exit
    end

    private

    def file_path
      Pathname.new(FileUtils.pwd).join("worklog_report.csv")
    end

    def parse_options(args)
      args = args.dup
      parser.parse!(args)
      @params = extract_params(args)
    end

    def parser
      parser = OptionParser.new do |opts|
        desc = "Usage: jiralo [options] PROJECT USER [FROM_DATE] [TO_DATE]"
        opts.banner = desc
        opts.on("-h", "--help", "Prints this help") { help }
      end
    end

    def extract_params(args)
      out_params = args.each.with_index.inject({}) do |obj, (arg, index)|
        obj[PARAM_KEYS[index]] = arg.to_s
        obj
      end
      evaluate_params(out_params)
    end

    def evaluate_params(hash)
      hash[:from] ||= Date.today.beginning_of_week.to_s
      hash[:to]   ||= Date.today.end_of_week.to_s
      hash[:from]   = Date.parse(hash[:from])
      hash[:to]     = Date.parse(hash[:to])
      hash
    end
  end
end
