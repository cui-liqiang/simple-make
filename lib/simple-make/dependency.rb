require "simple-make/path_helper"

class Dependency
  include PathHelper
  attr_reader :include, :scope

  def initialize map, path_mode = :absolute
    raise wrong_format_msg(map) if !(map.is_a? Hash) or map[:include].nil? or map[:lib].nil?

    @include = get_path(path_mode, map[:include])
    @lib = get_path(path_mode, map[:lib])
    @scope = map[:scope] || :compile
  end

  def lib_name
    if @lib_name.nil?
      matches = @lib.match /.*\/lib([^\/]*)\.a/
      raise "lib name format is wrong, it should be [libxxx.a]" if matches.nil?
      @lib_name = matches[1]
      raise "lib name format is wrong, it should be [libxxx.a], and the xxx should not be empty" if @lib_name.empty?
    end
    @lib_name
  end

  def lib_path
    if @lib_path.nil?
      matches = @lib.match /(.*\/)[^\/]*/
      @lib_path = matches[1]
    end
    @lib_path
  end

  private
  def wrong_format_msg(map)
    "#{map.inspect} is not a map, please present dependencies in format {include: <include_path>, lib: <lib_file_name>}"
  end
end