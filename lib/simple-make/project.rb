require "simple-make/dependency"
require "simple-make/search_path"
require "simple-make/dir_traverser"
require "simple-make/path_helper"
require "simple-make/project_factory"
require "erb"

class Project
  include PathHelper
  attr_reader :output_path
  attr_writer :name, :src_suffix, :app_path, :test_path, :package_type
  attr_accessor :path_mode

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
    @cc = "g++ -O0 -g3 -Wall"
    @link = "g++"
    @src_suffix = "cc"
    @path_mode = options[:path_mode] || :absolute
    @package_type = :executable
  end

  def depend_on(*deps)
    raise "depend_on only accept array of dependencies, use [] to wrap your dependency if there is only one" if !(deps.is_a? Array)
    @deps += deps.map{|depHash| Dependency.new(depHash, @path_mode)}
  end

  def depend_on_project(*projects)
    @dep_projects += projects.map{|params| ProjectFactory.create_from_relative_path(params)}
  end

  def srcs
    all_sources_in(@app_path)
  end

  def test_srcs
    all_sources_in(@test_path)
  end

  def prod_srcs
    all_sources_in(@prod_path)
  end

  def sub_folders_in_target_folder
    folders = []
    {"app" => @app_path, "prod" => @prod_path, "test" => @test_path}.each_pair do |k,v|
      folders += all_output_dirs_related_to(k, v)
    end
    folders.map{|raw| "build/#{raw}"}.join(" \\\n")
  end

  def header_search_path *paths
    raise "search path only accept array of paths, use [] to wrap your search paths if there is only one" if !(paths.is_a? Array)
    @includes += paths.map{|path| SearchPath.new(path, @path_mode)}
  end

  def compile_command_with_flag cc
    @cc = cc
  end

  def link_command_with_flag link
    @link = link
  end

  def generate_make_file(filename = "Makefile")
    puts "generating makefile for project #{@name} and its deps"
    generate_makefile_for_dep_project
    generate_make_file_for_current_project(filename)
  end

  def generate_make_file_for_current_project(filename)
    puts "generating makefile for project #{@name}"
    makefile = ERB.new(File.open(template_file("makefile.erb")).read)
    File.open("#{@workspace}/#{filename}", "w") do |f|
      f.write makefile.result(binding)
    end
  end

  def pack_dep_projects
    @dep_projects.map(&:pack_self_command).join("\n\t")
  end

  def package_file
    puts "in package_file for project #{@name}"
    puts "@package_type is:"
    p @package_type
    return "#{@output_path}/lib#{@name}.a" if(@package_type == :archive)
    return "#{@output_path}/#{@name}" if(@package_type == :executable)
  end

  def dep_projects_outputs
    @dep_projects.map(&:package_file).join(" ")
  end

  def generate_makefile_for_dep_project
    puts "generating makefile for dep projects"
    puts "projects: #{@dep_projects}"
    @dep_projects.each(&:generate_make_file)
  end

  def package_part
    package = ERB.new(File.open(template_file("#{@package_type}_package.erb")).read)
    package.result(binding)
  end

  [:compile, :test, :prod].each do |scope|
    define_method("#{scope}_time_search_path_flag") do
      return search_path_flag(:compile) if scope == :compile
      search_path_flag(:compile, scope)
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
  def template_file(template)
    File.expand_path(File.dirname(__FILE__) + "/../../template/#{template}")
  end

  def all_output_dirs_related_to(label, base)
    within_workspace do
      File.exist?(base) ?
      (DirTraverser.all_folders_in_path("#{base}/#{@source_folder_name}")).map do |origin|
        label + origin.sub("#{base}/#{@source_folder_name}", "")
      end << label : []
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