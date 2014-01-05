require "simple-make/project"
require "simple-make/std_logger"
require "optparse"

class Cli
  def create_project args
    options = {workspace: File.absolute_path(".")}
    parser = OptionParser.new do |opts|
      opts.on("--relative-path") do
        options[:path_mode] = :relative
      end
      opts.on("-v") do
        $std_logger.level = Logger::DEBUG
      end
    end
    parser.parse(args)
    Project.new options
  end
end