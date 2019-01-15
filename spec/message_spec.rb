require 'spec_helper'

describe BuildComms::Message do
  before :all do
    @old_gap_server = ENV["GAP_SERVER"]
    ENV["GAP_SERVER"] = "spec"
  end

  before do
    @app = double("app")
    @person = double("person")
    @person.stub(:id).and_return(69)
    @person.stub(:email).and_return("richard@dunne.co")

    @app.stub(:id).and_return(122)
    @app.stub(:owner).and_return(@person)
    @app.stub(:title).and_return("my app")
    @app.stub(:repo_url).and_return("example.com")
    @app.stub(:icon).and_return("icon.png")
    @app.stub(:desc).and_return("description")
    @app.stub(:uuid).and_return("01234567890")
    @app.stub(:package).and_return("com.example")
    @app.stub(:version_string).and_return("1.0.0")
    @app.stub(:version_code).and_return(5)
    @app.stub(:debug_flag).and_return(true)
    @app.stub(:hydrates).and_return(true)
    @app.stub(:hydration_domain).and_return( "build.phonegap.com" )
    @app.stub(:debug_domain).and_return( "debug.build.phonegap.com" )
    @app.stub(:debug_key).and_return( "abc123" )
    @app.stub(:time_built).and_return("some time")
    @app.stub(:auth_token).and_return("some token")
    @app.stub(:build_token).and_return("2376")
    @person.stub(:username).and_return("teddy")
    @person.stub(:group)
    
    @hash = <<-HASH
      {"id":122, "key":"#{@app.uuid}.zip", "title":"#{@app.title}","plugins":[{"a":1},{"a":2}],
      "author":"#{@app.owner.username}", "origin":"remote", "debug_flag":true,
      "platform":"android", "url":"#{@app.repo_url}", "icon":"#{@app.icon}",
      "desc":"#{@app.desc}", "uuid":"#{@app.uuid}", "package":"#{@app.package}",
      "version_string":"#{@app.version_string}", "version_code":"#{@app.version_code}", "error":"FATAL ERORR",
      "hydrates":true, "time_built":"some time", "auth_token":"some token",
      "hydration_domain":"build.phonegap.com", "build_token":"2376",
      "debug_domain":"debug.build.phonegap.com", "debug_key":"abc123" }
    HASH
    @hash = @hash.strip
  end

  describe "#from_app" do
    it "should generate a Message from an app" do
      lambda {
        msg = BuildComms::Message.from_app(@app)
      }.should_not raise_error
    end

    it "should fail with an error message when UUID is not set" do
      @app.stub(:uuid).and_return(nil)
      lambda {
        msg = BuildComms::Message.from_app(@app)
      }.should raise_error(BuildComms::Message::ValidationError)
    end

    it "should fail with an error message when person is nil" do
      @app.stub(:owner).and_return(nil)
      lambda {
        msg = BuildComms::Message.from_app(@app)
      }.should raise_error(NoMethodError)
    end

    it "should set the package to the default value, if not present" do
      @app.stub(:package).and_return(nil)
      msg = BuildComms::Message.from_app(@app)
      msg.package.should == "com.phonegap.www"
    end

    it "should set the package to the default value, if empty" do
      @app.stub(:package).and_return("")
      msg = BuildComms::Message.from_app(@app)
      msg.package.should == "com.phonegap.www"
    end

    it "should set author to the person's email" do
      msg = BuildComms::Message.from_app(@app)
      msg.author.should == "richard@dunne.co"
    end

    it "should set person_id to the person's id" do
      msg = BuildComms::Message.from_app(@app)
      msg.person_id.should == 69
    end
  end

  describe "self#origin" do
    it "should return the origin based on server name and Rails environment" do
      BuildComms::Message.origin.should == "spec-test"
    end

    it "should return the Rails environment with no server name set" do
      ENV["GAP_SERVER"] = nil
      BuildComms::Message.origin.should == "test"
      ENV["GAP_SERVER"] = "spec"
    end

    it "should have that default origin set on each Message" do
      @bm = BuildComms::Message.from_app(@app)
      @bm.origin.should == "spec-test"
    end

    it "should allow the origin to be overridden" do
      @bm = BuildComms::Message.from_app @app, :origin => "foo-bar"
      @bm.origin.should == "foo-bar"
    end
  end

  describe "with a valid msg" do
    before do
      @msg = BuildComms::Message.from_app(@app)
      @msg.plugins = [{ :a => 1 }, {:a => 2}]
      @msg.platform = "symbian"
    end

    it "should serialize to valid JSON" do
      lambda {
        @msg.to_json
       }.should_not raise_error
    end

    it "should return a correct S3 key for a build" do
      @msg.done_key.should == @msg.uuid + "-" + @msg.platform + "-done.zip"
    end

    it "should allow access to the id field" do
      @msg.id.should == 122
    end

    it "should allow access to the key field" do
      @msg.key.should == "01234567890.zip"
    end

    it "should allow access to the plugins field" do
      @msg.plugins[0][:a].should == 1
      @msg.plugins[1][:a].should == 2
    end

    it "should allow access to the title field" do
      @msg.title.should == "my app"
    end

    it "should allow access to the url field" do
      @msg.url.should == "example.com"
    end

    it "should allow access to the icon field" do
      @msg.icon.should == "icon.png"
    end

    it "should allow access to the desc field" do
      @msg.desc.should == "description"
    end

    it "should allow access to the uuid field" do
      @msg.uuid.should == "01234567890"
    end

    it "should allow access to the build_token field" do
      @msg.build_token.should == "2376"
    end

    it "should allow access to the package field" do
      @msg.package.should == "com.example"
    end

    it "should allow access to the version_string field" do
      @msg.version_string.should == "1.0.0"
    end

    it "should allow access to the version_code field" do
      @msg.version_code.should == 5
    end

    it "should allow access to the author field" do
      @msg.author.should == "richard@dunne.co"
    end

    it "should allow access to the person_id field" do
      @msg.person_id.should == 69
    end

    it "should set origin to the class's origin" do
      @msg.origin.should == BuildComms::Message.origin
    end

    it "should set build_plugins to false" do
      @msg.build_plugins.should be_falsey
    end

    it "should set debug_flag to true" do
      @msg.debug_flag.should be_truthy
    end

    it "should set hydrates to true" do
      @msg.hydrates.should be_truthy
    end

    it "should set hydration_domain to build.phonegap.com" do
      @msg.hydration_domain.should == "build.phonegap.com" 
    end

    it "should set debug_domain to debug.build.phonegap.com" do
      @msg.debug_domain.should == "debug.build.phonegap.com" 
    end

    it "should set debug_key to abc123" do
      @msg.debug_key.should == "abc123" 
    end

    it "should set time_built to some time" do
      @msg.time_built.should == "some time"
    end

    it "should set auth_token to some token" do
      @msg.auth_token.should == "some token"
    end

    it "should allow removal of key" do
      @msg.auth_token.should == "some token"
      @msg.remove("auth_token")
      @msg.auth_token.should be_nil
    end
  end

  it "should have a method called to_json" do
    BuildComms::Message.should respond_to :to_json
  end

  it "should generate a BuildComms::Message from a JSON string" do
    lambda {
      msg = BuildComms::Message.from_hash(JSON.parse(@hash))
    }.should_not raise_error
  end

  describe "with a valid JSON string" do
    before do
      @msg = BuildComms::Message.from_hash(JSON.parse(@hash))
    end

    it "should allow access to the id field" do
      @msg.id.should == 122
    end

    it "should allow access to the key field" do
      @msg.key.should == "01234567890.zip"
    end

    it "should allow access to the title field" do
      @msg.title.should == "my app"
    end

    it "should allow access to the url field" do
      @msg.url.should == "example.com"
    end

    it "should allow access to the icon field" do
      @msg.icon.should == "icon.png"
    end

    it "should allow access to the plugins field" do
      @msg.plugins[0]["a"].should == 1
      @msg.plugins[1]["a"].should == 2
    end

    it "should allow access to the desc field" do
      @msg.desc.should == "description"
    end

    it "should allow access to the build_token field" do
      @msg.build_token.should == "2376"
    end

    it "should allow access to the uuid field" do
      @msg.uuid.should == "01234567890"
    end

    it "should allow access to the package field" do
      @msg.package.should == "com.example"
    end

    it "should allow access to the version_string field" do
      @msg.version_string.should == "1.0.0"
    end

    it "should allow access to the version_code field" do
      @msg.version_code.should == "5"
    end

    it "should allow access to the author field" do
      @msg.author.should == "teddy"
    end

    it "should read origin from the JSON string" do
      @msg.origin.should == "remote"
    end

    it "should populate the platform field" do
      @msg.platform.should == "android"
    end

    it "should populate the error correctly" do
      @msg.error.should == "FATAL ERORR"
    end

    it "should set the debug_flag correctly" do
      @msg.debug_flag.should be_truthy
    end
  end

  describe "default package" do
    before do
      @hash_obj = JSON.parse(@hash)
    end

    it "should be set when hash[package] is nil" do
      @hash_obj["package"] = nil
      msg = BuildComms::Message.from_hash(@hash_obj)

      msg.package.should == "com.phonegap.www"
    end

    it "should be set when hash[package] is empty" do
      @hash_obj["package"] = ""
      msg = BuildComms::Message.from_hash(@hash_obj)

      msg.package.should == "com.phonegap.www"
    end
  end

  describe "with a certificate" do
    before do
      @android_key = double('androidkey')
      @android_key.stub(:alias).and_return('foo')
      @android_key.stub(:key_pw).and_return('bar')
      @android_key.stub(:keystore_pw).and_return('baz')
      @android_key.stub(:extension).and_return('keystore')
      @android_key.stub(:data).and_return('a bunch of encoed data')

      @msg = BuildComms::Message.from_app(@app)
      @msg.platform = "android"
    end

    it "should allow the signed field to be set" do
      lambda { @msg.signed = true }.should_not raise_error
    end

    it "should allow cert_key to be set" do
      lambda { @msg.cert_key = "uuid-platform.extension" }.should_not raise_error
    end

    it "should allow cert_data to be set" do
      lambda { @msg.cert_data = { "a" => 1, "b" => 2 } }.should_not raise_error
    end

    describe "#attach_cert" do
      before do
        @msg.attach_cert(@android_key)
      end

      it "should set the signed field to true" do
        @msg.signed.should be_truthy
      end

      it "should set cert_key to the right value" do
        @msg.cert_key.should == "01234567890-android.keystore"
      end

      it "should set cert_data to have the relevant data" do
        @msg.cert_data.should == 'a bunch of encoed data'
      end
    end
  end

  after :all do
    ENV["GAP_SERVER"] = @old_gap_server
  end
end
