require "spec_helper"
require "fileutils"

describe "multi-projects" do
  def for_all_project
    Dir.chdir(@base_path) do
      [1,2,3].each do |num|
        yield "project#{num}"
      end
    end
  end

  def clean_build_dirs_and_makefile
    for_all_project do |project_name|
      FileUtils.rmtree "#{project_name}/build"
      FileUtils.rmtree "#{project_name}/Makefile"
    end
  end

  def check_executable_present
    for_all_project do |project_name|
      if project_name == "project1"
        File.exist?("#{project_name}/build/#{project_name}").should be_true
      else
        File.exist?("#{project_name}/build/lib#{project_name}.a").should be_true
      end
    end
  end

  def check_ut_executable_present
    for_all_project do |project_name|
      File.exist?("#{project_name}/build/#{project_name}_ut").should be_true
    end
  end

  def run_command command
    puts "running #{command}"
    system command
  end

  PROJECT_ROOT = File.expand_path(File.dirname(__FILE__) + "/../../")

  before(:each) do
    @base_path = PROJECT_ROOT + "/spec/functional/multi-project"
    clean_build_dirs_and_makefile
  end

  after(:each) do
    clean_build_dirs_and_makefile
  end

  context "project1 depend on project2 and project3" do
    it "should create artifacts for project2 and project3 when pack project1" do
      Dir.chdir "#{@base_path}/project1" do
        run_command "sm"
        run_command "make package"
      end
      check_executable_present
    end

    it "should compile, link project2/3 and run" do
      Dir.chdir "#{@base_path}/project1" do
        run_command "sm"
        run_command "make run"
      end
      check_executable_present
    end

    it "should create test executables for project2 and project3 when run testall on project1", not_on_ci: true do
      Dir.chdir "#{@base_path}/project1" do
        run_command "sm"
        run_command "make testall"
      end
      check_ut_executable_present
    end
  end

  context "root dummy project depend on project1/2/3" do
    def clean_root_makefile
      Dir.chdir @base_path do
        run_command "rm Makefile"
      end
    end

    before(:each) do
      clean_root_makefile
    end

    after(:each) do
      clean_root_makefile
    end

    it "should package project1/2/3 when run package on root project" do
      Dir.chdir @base_path do
        run_command "sm"
        run_command "make package"
      end
      check_executable_present
    end

    it "should test project1/2/3 when run test on root project", not_on_ci: true do
      Dir.chdir @base_path do
        run_command "sm"
        run_command "make test"
      end
      check_ut_executable_present
    end
  end
end