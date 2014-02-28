require 'SysVIPC'
require 'fileutils'

# Größenbeschränkte queue auf IPC-Basis
# http://commons.apache.org/proper/commons-collections/javadocs/api-release/org/apache/commons/collections4/queue/CircularFifoQueue.html

class CircularMessageQueue

  attr_accessor :logger

  MAX_MSGLEN = 100
  TYPE = 1
  MAX_MSGCOUNT = 5
  PROJECT_ID = 1
  KEY_FILE = '/tmp/ipc_test'

  def initialize
    @ipcmq = SysVIPC::MessageQueue.new(key, SysVIPC::IPC_CREAT | 0600)
    set_queue_size
  end

  def <<(str)
    @ipcmq.send(TYPE, str, SysVIPC::IPC_NOWAIT)
  rescue Errno::EAGAIN
    # Zu viele Einträge in der queue, dann einen droppen
    drop_old_message
    retry
  end

  def receive_loop(&block)
    loop do
      begin
        msg = @ipcmq.receive(TYPE, MAX_MSGLEN, SysVIPC::IPC_NOWAIT)
        block.call(msg)
      rescue Errno::ENOMSG
        sleep 1
      end
    end
  end

  private

  def drop_old_message
    msg = @ipcmq.receive(TYPE, MAX_MSGLEN, SysVIPC::IPC_NOWAIT)
    logger.warn "dropped one message: #{msg}" if logger
  rescue Errno::ENOMSG
  end

  def key
    FileUtils.touch(KEY_FILE)
    SysVIPC::ftok(KEY_FILE, PROJECT_ID)
  end

  def set_queue_size
    config = @ipcmq.ipc_stat
    # Die Größe der queue beschränken
    config.msg_qbytes = MAX_MSGLEN * MAX_MSGCOUNT
    @ipcmq.ipc_set(config)
  end
end
