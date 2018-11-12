module BuildComms
  class Tags
    class << self

      def client
        @client || @client = Aws::EC2::Client.new
      end

      def get
        result = {}

        begin
          instance_id = open('http://169.254.169.254/latest/meta-data/instance-id').read 
          filter = { filters: [ { name: "resource-id", values: [ instance_id ] } ] }
          resp = client.describe_tags(filter).tags.map { |tag| 
            result[tag.key.upcase] = tag.value
          }
        rescue Timeout::Error, SocketError, OpenURI::HTTPError ; end
        result
      end
    end
  end
end
