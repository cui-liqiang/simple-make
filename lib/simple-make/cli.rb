require "simple-make/project"
require "optparse"

class Cli
  def create_project args
    options = {workspace: File.absolute_path(".")}
    parser = OptionParser.new do |opts|
      opts.on("--relative-path") do
        options[:path_mode] = :relative
      end
    end
    parser.parse(args)
    Project.new options
  end
end