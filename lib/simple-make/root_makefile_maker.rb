require "simple-make/normal_makefile_maker"

class RootMakefileMaker < NormalMakefileMaker
  def initialize project, context
    super project, context, "root_makefile"
  end
end