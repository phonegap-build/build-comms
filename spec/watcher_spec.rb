require "spec_helper.rb"

describe BuildComms::Watcher do
  it "should have a watch method" do
    BuildComms::Watcher.should respond_to "watch"
  end
end
