require "simple-make/package_type/package"

class ExecutablePackage < Package
  def initialize project
    super(project, "executable")
  end

  def package_file
    "#{@project.output_path}/#{@project.name}"
  end
end