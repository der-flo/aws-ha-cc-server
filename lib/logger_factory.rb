require 'logger'

module LoggerFactory
  def self.logger(filename)
    l = Logger.new(filename)
    l.formatter = proc do |severity, datetime, progname, msg|
      dt = datetime.strftime('%Y-%m-%d %H:%M:%S')
      msg.split("\n").collect do |line|
        "#{dt} #{severity}: #{line}\n"
      end.join
    end
    l
  end
end
