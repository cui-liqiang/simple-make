require "simple-make/path_helper"

class SearchPath
  include PathHelper
  attr_reader :path, :scope

  def initialize map, path_mode = :absolute
    raise wrong_format_msg(map) if !(map.is_a? Hash) or map[:path].nil?

    @path = get_path(path_mode, map[:path])
    @scope = map[:scope] || :compile
  end

private
  def wrong_format_msg(map)
    "#{map.inspect} is not a map, please present dependencies in format {path: <include_path>, type: <compile/test/prod(external is default value)>}"
  end
end