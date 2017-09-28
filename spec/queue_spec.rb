require "spec_helper.rb"

describe BuildComms::Queue do
  it "should have a method called queue" do
    BuildComms::Queue.should respond_to :queue
  end

  describe "#queue" do
    it "should require one argument" do
      lambda { BuildComms::Queue.queue }.should raise_error(ArgumentError)
    end
  end
end
