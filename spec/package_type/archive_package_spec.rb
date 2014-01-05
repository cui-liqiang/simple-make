require "spec_helper"
require "simple-make/package_type/archive_package"
require "simple-make/project"

describe ArchivePackage do
  before(:each) do
    project = Project.new
    project.name = "archive-project"
    @executable = ArchivePackage.new(project)
  end

  it "should give package name as a static lib" do
    @executable.package_file.should == "build/libarchive-project.a"
  end
end