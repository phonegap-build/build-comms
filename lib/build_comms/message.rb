module BuildComms
  class Message
    class ValidationError < ArgumentError ; end

    class << self
      def fields(*args)
        @@fields = args.map { |s| s.to_s }
      end
    end

    fields :id, :key, :title, :author, :url, :icon, :project_type,
      :desc, :uuid, :package, :version_string, :version_code, :origin,
      :platform, :error, :signed, :cert_key, :cert_data, :build_plugins,
      :debug_flag, :s3_icon_url, :phonegap_version, :hydrates, :person_id,
      :time_built, :auth_token, :hydration_domain, :build_unique_id,
      :duration, :plugins, :debug_domain, :debug_key, :build_token,
      :s3_manifest_url, :s3_package_url, :s3_usage, :s3_key, :cache,
      :compile_duration, :gimlet_server, :gimlet_version, :build_number,
      :build_log, :gimlet_log

    @@default_pkg = "com.phonegap.www"

    def initialize
      @hash = Hash.new
    end

    # some meta-programming to simplify adding new fields
    def method_missing(sym, *args, &block)
      str = sym.to_s
      matches = nil

      if str == "[]"
        str = args.shift
      elsif str == "[]="
        str = "#{ args.shift }="
      end

      if @@fields.include?(str)
        @hash[str]
      elsif matches = str.match(/(.*)=$/) and @@fields.include?(matches[1])
        @hash[matches[1]] = args.first
      else
        super(sym, *args, &block)
      end
    end

    # method_missing approach won't work with id - do it manually
    def id
      @hash["id"]
    end

    def id=(x)
      @hash["id"] = x
    end

    def self.from_hash(h)
      m = Message.new

      @@fields.each do |f|
        m[f] = h[f] unless h[f].nil?
      end

      m.key         = h["key"] || "#{ h["uuid"] }.zip"
      m.package     = Utils.string_or_default(h["package"], @@default_pkg)

      m
    end
    
    def self.from_app(app, opt = {})
      raise ValidationError unless app.uuid

      m = Message.new

      @@fields.each do |f|
        value = nil

        begin
          value = app.send(f)
        rescue Exception
        end

        m[f] = value unless value.nil?
      end

      m.key         = "#{ app.uuid }.zip"
      m.url         = app.repo_url
      m.package     = Utils.string_or_default(app.package, @@default_pkg)
      m.origin      = opt[:origin] || self.origin
      m.author      = app.owner.email
      m.person_id   = app.owner.id

      m
    end

    def self.origin(environment='test')
      ENV["GAP_SERVER"] ? "#{ ENV["GAP_SERVER"] }-#{ environment }" : "#{ environment }"
    end

    def to_s
      @hash.to_json
    end
    
    def done_key
      "#{ uuid }-#{ platform }-done.zip"
    end

    def attach_cert(certificate)
      self.signed = true
      self.cert_key = "#{ uuid }-#{ platform }.#{ certificate.extension }"
      self.cert_data = certificate.data
      true
    end
  end
end
