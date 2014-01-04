require "spec_helper"
require "simple-make/cli"

describe Cli do
  before(:each) do
    @cli = Cli.new
  end
  it "should set path_mode to be relative if set to be relative on command line" do
    @cli.create_project("--relative-path").instance_eval{@path_mode}.should == :relative
  end
end