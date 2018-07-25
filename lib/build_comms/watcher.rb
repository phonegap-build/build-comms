module BuildComms
  class Watcher
    def self.watch(queue_name, interval=10, opt = {})
      $interrupt = false

      # set up logger
      log = opt[:logger]
      if !log 
        log = Logger.new(STDOUT)
        log.level = Logger::INFO
        log.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime.utc.round(10).iso8601(3)} #{severity} #{msg}\n"
        end
      end

      trap("INT") {
        puts "INT received: exit after task completes"
        $interrupt = true
      }

      trap("TERM") {
        puts "TERM received: exit after task completes"
        $interrupt = true
      }

      queue = BuildComms::Queue.queue queue_name
      poller = Aws::SQS::QueuePoller.new queue.queue_url

      last_poll = Time.new
      poller.before_request do |stats|
        throw :stop_polling if $interrupt
        if Time.now - last_poll > 20
          log.info "QUEUE=#{queue_name} - bored"
          last_poll = Time.new
        end
      end

      poller.poll(wait_time_seconds:interval) do |msg|
        begin
          yield msg
        rescue SocketError, AWS::Errors::Base, Net::OpenTimeout => e
          msg = "QUEUE=#{queue_name} gonna move on but heres the deets: (#{e.message})"
          log.error msg
          log.error e
          throw :skip_delete
        end
      end
    end
  end
end
