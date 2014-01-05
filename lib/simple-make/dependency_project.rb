class DependencyProject
  attr_reader :scope

  def initialize project, options
    @project = project
    @relative_path = options[:relative_path]
    @scope = options[:scope] || :compile
  end

  def package_command
    make_command("package")
  end

  def test_command
    make_command("test")
  end

  def package_file
    "#{@relative_path}/#{@project.package_file}"
  end

  def export_search_path_flag
    @project.prod_time_search_path_flag
  end

  def output_path
    "#{@relative_path}/#{@project.output_path}/*"
  end

  def generate_make_file
    @project.generate_make_file
  end

private
  def make_command(string)
    "make -C #{@relative_path} #{string}"
  end
end