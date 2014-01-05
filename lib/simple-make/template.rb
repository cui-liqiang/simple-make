class Template
  TEMPLATE_BASE_DIR = File.dirname(__FILE__) + "/../../template/"

  def self.template_content(name)
    content = ""
    File.open(File.expand_path(TEMPLATE_BASE_DIR + name + ".erb")) do |f|
      content = f.read
    end
    content
  end
end