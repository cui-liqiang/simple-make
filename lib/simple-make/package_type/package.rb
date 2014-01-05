require "simple-make/template"

class Package
  def initialize project, template_name
    @project = project
    @template_name = template_name
  end

  def package_file
    raise "not implemented, use subtype!"
  end

  def pack_deps_command
    package = ERB.new(Template.template_content("#{@template_name}_package"))
    package.result(binding)
  end

  def pack_dep_project_commands
    @project.dep_projects.map(&:pack_self_command).join("\n\t")
  end

  def dep_projects_output_names
    @project.dep_projects.map(&:package_file).join(" ")
  end
end