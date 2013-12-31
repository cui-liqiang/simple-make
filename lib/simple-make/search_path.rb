class SearchPath
  attr_reader :path, :scope
  def initialize map
    raise wrong_format_msg(map) if !(map.is_a? Hash) or map[:path].nil?

    @path = File.absolute_path(map[:path])
    @scope = map[:scope] || :compile
  end

private
  def wrong_format_msg(map)
    "#{map.inspect} is not a map, please present dependencies in format {path: <include_path>, type: <compile/test/prod(external is default value)>}"
  end
end