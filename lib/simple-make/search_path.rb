class SearchPath
  attr_reader :path, :type
  def initialize map
    raise wrong_format_msg(map) if !(map.is_a? Hash) or map[:path].nil?

    @path = File.absolute_path(map[:path])
    @type = map[:type] || :external
  end

private
  def wrong_format_msg(map)
    "#{map.inspect} is not a map, please present dependencies in format {path: <include_path>, type: <external/test/prod(external is default value)>}"
  end
end