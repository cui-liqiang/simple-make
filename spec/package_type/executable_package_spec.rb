require "spec_helper"
require "simple-make/package_type/executable_package"
require "simple-make/project"

describe ExecutablePackage do
  before(:each) do
    project = Project.new
    project.name = "executable-project"
    @executable = ExecutablePackage.new(project)
  end

  it "should give package name as a static lib" do
    @executable.package_file.should == "build/executable-project"
  end
end