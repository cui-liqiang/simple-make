require "simple-make/package_type/archive_package"
require "simple-make/package_type/executable_package"

class PackageFactory
  def self.create_by_type type, project
    return ArchivePackage.new(project) if type == :archive
    return ExecutablePackage.new(project) if type == :executable
  end
end