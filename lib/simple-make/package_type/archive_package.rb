require "simple-make/package_type/package"

class ArchivePackage < Package
  def initialize project
    super(project, "archive")
  end

  def package_file
    "#{@project.output_path}/lib#{@project.name}.a"
  end
end