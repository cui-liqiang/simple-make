require "simple-make/dependency"
require "simple-make/search_path"
require "simple-make/dir_traverser"
require "simple-make/path_helper"
require "simple-make/project_factory"
require "simple-make/std_logger"
require "simple-make/template"
require "simple-make/normal_makefile_maker"
require "simple-make/root_makefile_maker"
require "simple-make/package_type/package_factory"

class Project
  include PathHelper
  attr_accessor :name, :src_suffix, :app_path, :test_path, :prod_path, :output_path, :compile_command_with_flag, :link, :source_folder_name
  attr_reader :dep_projects, :workspace, :makefile_name

  def initialize(options = {})
    @workspace = options[:workspace] || File.absolute_path(".")
    @name = @workspace.split("/").last
    @app_path = "app"
    @test_path = "test"
    @prod_path = "prod"
    @output_path = "build"
    @source_folder_name = "src"
    @deps = []
    @dep_projects = []
    @includes = []
    @compile_command_with_flag = "g++ -O0 -g3 -Wall"
    @link_command_with_flag = "g++"
    @src_suffix = "cc"
    @path_mode = options[:path_mode] || :absolute
    self.package_type = :executable
    @makefile_name = options[:makefile] || "Makefile"
    @makefile_maker = NormalMakefileMaker.new(self, binding)
  end

  def root_project
    @makefile_maker = RootMakefileMaker.new(self, binding)
  end

  def package_type= type
    @package = PackageFactory.create_by_type(type, self)
  end

  def depend_on(*deps)
    within_workspace do
      @deps += deps.map{|depHash| Dependency.new(depHash, @path_mode)}
    end
  end

  def depend_on_project(*projects)
    within_workspace do
      @dep_projects += projects.map{|params| ProjectFactory.create_from_relative_path(params)}
    end
  end

  def header_search_path *paths
    within_workspace do
      @includes += paths.map{|path| SearchPath.new(path, @path_mode)}
    end
  end

  def sub_folders_in_target_folder
    folders = []
    {"app" => @app_path, "prod" => @prod_path, "test" => @test_path}.each_pair do |k,v|
      folders += all_output_dirs_related_to(k, v)
    end
    folders.map{|raw| "#{@output_path}/#{raw}"}.join(" \\\n")
  end

  def generate_make_file
    @makefile_maker.generate_make_file
  end

  def package_file
    @package.package_file
  end

  def pack_dep_project_commands
    @package.pack_dep_project_commands
  end

  def package_part
    @package.pack_deps_command
  end

  def run_test_on_deps
    @dep_projects.map(&:test_command).join("\n\t")
  end

  [:compile, :test, :prod].each do |scope|
    define_method("#{scope}_time_search_path_flag") do
      return search_path_flag(:compile) if scope == :compile
      search_path_flag(:compile, scope)
    end

    define_method("#{scope}_time_srcs") do
      scope = :app if scope == :compile
      all_sources_in(send("#{scope}_path"))
    end
  end

  [:test, :prod].each do |scope|
    define_method("#{scope}_time_lib_path_flag") do
      lib_path_flag(:compile, scope)
    end

    define_method("#{scope}_time_lib_flag") do
      lib_name_flag(:compile, scope)
    end
  end

  def dep_projects_output_path
    @dep_projects.map(&:output_path).join(" ")
  end

private
  def all_output_dirs_related_to(scope, base)
    within_workspace do
      File.exist?(base) ?
      (DirTraverser.all_folders_in_path("#{base}/#{@source_folder_name}")).map do |origin|
        scope + origin.sub("#{base}/#{@source_folder_name}", "")
      end << scope : []
    end
  end

  def all_sources_in(base)
    within_workspace {DirTraverser.all_files_in_path("#{base}/#{@source_folder_name}").join(" \\\n")}
  end

  def within_workspace
    ret = ""
    Dir.chdir(@workspace) do
      ret = yield
    end
    ret
  end

  def lib_name_flag(*scopes)
    libs_name = []
    scopes.each do |scope|
      @deps.select { |dep| dep.scope == scope}.each{|dep| libs_name << dep.lib_name}
    end
    libs_name.map{|p| "-l#{p}"}.join(" ")
  end

  def lib_path_flag(*scopes)
    libs_path = []
    scopes.each do |scope|
      @deps.select { |dep| dep.scope == scope}.each{|dep| libs_path << dep.lib_path}
    end
    libs_path.map{|p| "-L#{p}"}.join(" ")
  end

  def search_path_flag(*scopes)
    includes = [within_workspace{"-I#{get_path(@path_mode, @app_path)}/include"}]

    scopes.each do |scope|
      ex_includes = @includes.select { |include| include.scope == scope}.map(&:path)
      ex_includes += @deps.select { |dep| dep.scope == scope}.map(&:include)
      includes += ex_includes.map { |include| "-I#{include}" }
      includes += @dep_projects.select{|dep_project| dep_project.scope == scope}.map(&:export_search_path_flag)
    end
    includes.join(" ")
  end
end