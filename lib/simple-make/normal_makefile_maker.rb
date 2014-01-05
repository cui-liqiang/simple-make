require "simple-make/std_logger"
require "simple-make/template"
require "erb"

class NormalMakefileMaker
  def initialize project, context, template = "makefile"
    @project = project
    @makefile_template = template
    @context = context
  end

  def generate_make_file
    $std_logger.debug "generating makefile for project #{@project.name} and its deps"
    generate_makefile_for_dep_project
    generate_make_file_for_current_project
  end

  def generate_makefile_for_dep_project
    $std_logger.debug "generating makefile for dep projects"
    $std_logger.debug "projects: #{@project.dep_projects}"
    @project.dep_projects.each(&:generate_make_file)
  end

  def generate_make_file_for_current_project
    $std_logger.debug  "generating makefile for project #{@project.name}"
    makefile = ERB.new(Template.template_content(@makefile_template))
    File.open("#{@project.workspace}/#{@project.makefile_name}", "w") do |f|
      f.write makefile.result(@context)
    end
  end
end