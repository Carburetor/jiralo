require "optparse"
require "jiralo/report_params"
require "pathname"
require "fileutils"

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
        opts.banner = "Usage: jiralo [options] PROJECT USER FROM_DATE TO_DATE"
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
      hash[:from] = Date.parse(hash[:from]) if hash[:from]
      hash[:to]   = Date.parse(hash[:to])   if hash[:to]
      hash
    end
  end
end
