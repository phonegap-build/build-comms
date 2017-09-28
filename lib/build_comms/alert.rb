module BuildComms
  class Alert
    class << self

      def client
        @snsclient || @snsclient = Aws::SNS::Client.new
      end

      def notify sns_arn, subject, body=nil
        subject = "[PGB] #{subject}"
        client.publish :topic_arn => sns_arn,
          :subject => subject,
          :message => body || subject
      end

      def wakeup sns_arn, subject, body=nil
        subject = "[PGB URGENT] #{subject}"
        client.publish :topic_arn => sns_arn,
          :subject => subject,
          :message => body || subject
      end
    end
  end
end
