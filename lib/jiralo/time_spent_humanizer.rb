module Jiralo
  class TimeSpentHumanizer
    def self.humanize(seconds)
      minutes = (seconds / 60) % 60
      hours   = seconds / (60 * 60)

      format("%dh %dm", hours, minutes)
    end
  end
end
