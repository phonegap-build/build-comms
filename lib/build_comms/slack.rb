module BuildComms
  class SLACK
    class << self
      def send web_hook, msg, alert=false

        msg = "<!channel> #{msg}" if alert

        note = {
          text: msg,
          color: "good"
        }

        notifier = Slack::Notifier.new web_hook
        notifier.post attachments: [note]
      end

      def danger web_hook, msg, alert=false

        msg = "<!channel> #{msg}" if alert

        note = {
          text: msg,
          color: "danger"
        }

        notifier = Slack::Notifier.new web_hook
        notifier.post attachments: [note]
      end
    end
  end
end