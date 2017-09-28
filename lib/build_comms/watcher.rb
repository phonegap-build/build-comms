module BuildComms
  class Watcher
    def self.watch(queue_name, interval=10, opt = {})
      $interrupt = false

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

      poller.before_request do |stats|
        throw :stop_polling if $interrupt
        print "."
      end

      poller.poll(wait_time_seconds:interval) do |msg|
        begin
          print "\n"
          yield msg
        rescue SocketError, AWS::Errors::Base, Net::OpenTimeout => e
          puts "ERROR -- gonna move on but heres the deets: (#{e.message})"
          puts e
          throw :skip_delete
        end
      end
    end
  end
end
