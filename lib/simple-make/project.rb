require "simple-make/dependency"
require "simple-make/search_path"
require "simple-make/dir_traverser"
require "simple-make/path_helper"
require "erb"

class Project
  include PathHelper
  attr_writer :name, :src_suffix, :app_path, :test_path, :package_type

  def initialize(options = {})
    @name = default_name
    @app_path = "app"
    @test_path = "test"
    @prod_path = "prod"
    @output_path = "build"
    @source_folder_name = "src"
    @deps = []
    @includes = []
    @cc = "g++ -O0 -g3 -Wall"
    @link = "g++"
    @src_suffix = "cc"
    @path_mode = options[:path_mode] || :absolute
    @package_type = :executable
  end

  def default_name
    File.absolute_path(".").split("/").last
  end

  def depend_on(*deps)
    raise "depend_on only accept array of dependencies, use [] to wrap your dependency if there is only one" if !(deps.is_a? Array)
    @deps += deps.map{|depHash| Dependency.new(depHash, @path_mode)}
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
    makefile = ERB.new(File.open(template_file("makefile.erb")).read)
    File.open(filename, "w") do |f|
      f.write makefile.result(binding)
    end
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

private
  def template_file(template)
    File.expand_path(File.dirname(__FILE__) + "/../../template/#{template}")
  end

  def all_output_dirs_related_to(label, base)
    return [] if !File.exist?(base)
    (DirTraverser.all_folders_in_path("#{base}/#{@source_folder_name}")).map do |origin|
      label + origin.sub("#{base}/#{@source_folder_name}", "")
    end << label
  end

  def all_sources_in(base)
    DirTraverser.all_files_in_path("#{base}/#{@source_folder_name}").join(" \\\n")
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
    includes = ["-I#{get_path(@path_mode, @app_path)}/include"]
    scopes.each do |scope|
      ex_includes = @includes.select { |include| include.scope == scope}.map(&:path)
      ex_includes += @deps.select { |dep| dep.scope == scope}.map(&:include)
      includes += ex_includes.map { |include| "-I#{include}" }
    end
    includes.join(" ")
  end
end