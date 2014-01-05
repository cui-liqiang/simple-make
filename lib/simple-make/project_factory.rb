require "simple-make/dependency_project"

class ProjectFactory
  def self.create_from_relative_path options
    build_file_path = options[:relative_path] + "/build.sm"
    raise "#{build_file_path} doesn't exist, cannot depend on project #{options[:relative_path]}, abort!" if !File.exist? build_file_path

    project = Project.new workspace: File.absolute_path(options[:relative_path])
    project.instance_eval(File.open(build_file_path).read)
    DependencyProject.new(project, options)
  end
end