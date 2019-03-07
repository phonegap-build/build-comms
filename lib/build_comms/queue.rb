module BuildComms
  class Queue 
    class << self

      def client
        @client || @client = Aws::SQS::Client.new
      end

      def queue_length queue_name
        opts = {
          queue_url: client.get_queue_url({ queue_name: queue_name }).queue_url,
          attribute_names: ["ApproximateNumberOfMessages"]
        }
        return client.get_queue_attributes(opts).attributes["ApproximateNumberOfMessages"]
      end

      def queue queue_name, attrs = { :VisibilityTimeout => "300" }
        opts = { :queue_name => queue_name, :attributes => attrs }
        return Queue.new client.create_queue(opts).queue_url
      end
    end
  end

  private

  class Queue

    attr_reader :queue_url

    def initialize queue_url
      @queue_url = queue_url
    end

    def send_message msg
      BuildComms::Queue.client.send_message({ :queue_url => @queue_url, :message_body => msg })
    end
  end
end
