module BuildComms
  class SNS
    class << self

      def client
        @client || @client = Aws::SNS::Client.new
      end

      def send topic, msg, subject=nil
        client.publish({
          topic_arn: topic,
          message: msg,
          subject: subject
        })
      end

    end
  end
end