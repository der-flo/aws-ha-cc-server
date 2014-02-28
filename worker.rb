require 'bundler/setup'
$LOAD_PATH << File.join(__dir__, 'lib')

require 'logger_factory'
require 'circular_message_queue'

logger = LoggerFactory.logger('receiver.log')

queue = CircularMessageQueue.new
queue.logger = logger

logger.info 'receiver starts loop...'
logger.info "A\nB"

queue.receive_loop do |msg|
  logger.info "got message: #{msg}"
  out = `start chef-solo`
  logger.info out
end

#pid = Process.spawn()
#Process.detach(pid)
