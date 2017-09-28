require "spec_helper.rb"

describe BuildComms::Store do
  it "should have a method called get" do
    BuildComms::Store.should respond_to :get
  end

  describe "#get" do
    it "should require two arguments" do
      BuildComms::Store.method(:get).arity.should be 2
    end
  end

  it "should have a method called put" do
    BuildComms::Store.should respond_to :put
  end

  describe "#get" do
    it "should require two arguments" do
      BuildComms::Store.method(:get).arity.should be 2
    end
  end

  describe "#get_file" do
    it "should require two arguments" do
      BuildComms::Store.method(:get_file).arity.should be 3
    end
  end

  it "should have a method called put" do
    BuildComms::Store.should respond_to :put
  end

  describe "#put" do
    before do
      @mock_object = double(Aws::S3::Object)
      @mock_client = double(Aws::S3::Client)
      BuildComms::Store.stub(:client).and_return @mock_client
    end

    describe " - arity" do
      before do
        @mock_client.should_receive(:put_object).with(anything()).and_return(@mock_object)
      end

      it "should accept three arguments" do
        lambda { BuildComms::Store.put "key", "some-data", "bucket" }.should_not raise_error
      end

      it "should accept five arguments" do
        lambda { 
          BuildComms::Store.put "key", "some-data", "bucket", "headers", "permissions"
        }.should_not raise_error
      end
    end
  end

  describe "#put_file" do
    before do
      @mock_object = double(Aws::S3::Object)
      @mock_client = double(Aws::S3::Client)
      File.stub(:open).and_yield "file contents"
      BuildComms::Store.stub(:client).and_return @mock_client
    end

    describe " - arity" do
      before do
        @mock_client.should_receive(:put_object).and_return(true)
      end

      it "should accept three arguments" do
        lambda { BuildComms::Store.put_file "key", "file-path", "bucket" }.should_not raise_error
      end

      it "should accept five arguments" do
        lambda { 
          BuildComms::Store.put_file "key", "file-path", "bucket", "headers", "permissions" 
        }.should_not raise_error
      end
    end
  end

  describe "#get_url" do
    it "should return false if the url can't be parsed" do
      BuildComms::Store.get_url("http://google.com").should be_falsey
    end

    describe "when the url can be parsed as s3" do
      before do
        BuildComms::Store.stub(:get).and_return("some get content")
        @url = "http://s3.amazonaws.com/bucket.name/key/is/all.this"
      end

      it "should not return false" do
        BuildComms::Store.get_url(@url).should_not be_falsey
      end

      it "should call get with the right params" do
        BuildComms::Store.should_receive(:get).
          with("key/is/all.this", "bucket.name")

        BuildComms::Store.get_url(@url)
      end
    end
  end

  describe "#signed_url" do
    before do
      @mock_signer = double(Aws::S3::Presigner)
      Aws::S3::Presigner.stub(:new).and_return @mock_signer
    end

    it "should pass on the expected message" do
      @mock_signer.should_receive(:presigned_url).with(:get_object, {:bucket=>"bucket", :key=>"key.zip", :expires_in=>300})

      BuildComms::Store.signed_url "bucket", "key.zip"
    end

    it "should pass on the expected message (with filename)" do
      @mock_signer.should_receive(:presigned_url).with(:get_object, {:bucket=>"bucket", :key=>"key.zip", :expires_in=>300, :response_content_disposition=>"attachment; filename=filename.ext"})

      BuildComms::Store.signed_url "bucket", "key.zip", 300, "filename.ext"
    end
  end

  describe "#archive" do
    before do
      Aws::S3::Client.any_instance.stub(:delete_object).and_return true
      Aws::S3::Client.any_instance.stub(:copy_object).and_return true
    end

    it "should pass on the expected message if from url" do
      url = "http://s3.amazonaws.com/bucket/IosKey/key.zip"
      Aws::S3::Client.any_instance.should_receive(:delete_object).with({:bucket=>"bucket", :key=>"IosKey/key.zip" })
      Aws::S3::Client.any_instance.should_receive(:copy_object).with({:bucket=>"archive_bucket", :key=>"bucket/IosKey/key.zip", :storage_class=>"REDUCED_REDUNDANCY", :server_side_encryption=>"AES256", :copy_source=>"bucket/IosKey/key.zip"})

      BuildComms::Store.archive(url, "archive_bucket")
    end
  end

  describe "#signed_url_from_url" do
    before do
      @mock_signer = double(Aws::S3::Presigner)
      Aws::S3::Presigner.stub(:new).and_return @mock_signer
    end

    it "should pass on the expected message" do
      url = "http://s3.amazonaws.com/bucket/IosKey/key.zip"
      @mock_signer.should_receive(:presigned_url).with(:get_object, {:bucket=>"bucket", :key=>"IosKey/key.zip", :expires_in=>300})

      BuildComms::Store.signed_url_from_url(url)
    end
  end
end
