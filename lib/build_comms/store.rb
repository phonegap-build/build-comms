module BuildComms
  class Store
    class << self
      def client
        @client || @client = Aws::S3::Client.new
      end

      def get (key, bucket_name)
        get_object(key, bucket_name).body.read
      end

      def get_file (key, bucket_name, filepath)
        get_object(key, bucket_name, { response_target: filepath })
      end

      def put (key, body, bucket_name, headers = {}, permission = nil)
        opts = {}
        opts[:acl] = "public-read" if permission == "public-read"
        opts[:content_type] = headers['content-type'] unless headers['content-type'].nil?
        opts[:content_disposition] = headers['content-disposition'] unless headers['content-disposition'].nil?
        opts[:server_side_encryption] = headers['server_side_encryption'] unless headers['server_side_encryption'].nil?

        opts[:bucket] = bucket_name
        opts[:key] = key
        opts[:body] = body
        client.put_object opts
      end

      def put_file (key, filepath, bucket_name, headers = {}, permission = nil)
        File.open(filepath, 'rb') do |body|
          put key, body, bucket_name, headers, permission
        end
      end

      def archive (url, archive_bucket)
        bucket, key = parse_url(url)
        archive_object(key, bucket, archive_bucket)
      end

      def get_url url
        bucket, key = parse_url(url)

        return false if bucket.nil?
        get key, bucket
      end

      def signed_url bucket_name, key, filename=nil, expires=300
        presigner = Aws::S3::Presigner.new(:client => @client)
        opts = { :bucket=>bucket_name, :key=>key, expires_in: expires }
        if filename
          opts[:response_content_disposition] = "attachment; filename=#{filename}"
        end
        presigner.presigned_url :get_object, opts
      end

      def signed_url_from_url url, filename=nil, expires=300
        bucket, key = parse_url(url)
        signed_url(bucket, key, filename, expires)
      end

      private

      def archive_object (key, bucket, archive_bucket)
        client.copy_object({
          :bucket => archive_bucket, 
          :key => "#{bucket}/#{key}",
          :storage_class => "REDUCED_REDUNDANCY",
          :server_side_encryption => "AES256",
          :copy_source => URI.encode("#{bucket}/#{key}")
        })
        client.delete_object({:bucket=>bucket, :key=>key})
        true
      end

      # returns bucket,key
      def parse_url url
        matches = url.match(/https?:\/\/[^\/]+\/([^\/]+)\/(.*)/)
        return matches.nil? ? [nil,nil] : [matches[1],matches[2]]
      end

      def get_object (key, bucket_name, opts = {})
        opts[:bucket] = bucket_name
        opts[:key] = key
        client.get_object opts
      end

    end
  end
end
