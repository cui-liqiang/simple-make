class DirTraverser
  def self.all_files_in_path base, found=[]
    return [] if !File.exist? base
    Dir.foreach(base) do |each|
      next if(each == "." || each == "..")

      full_name = base + "/" +each
      if File.directory? full_name
        all_files_in_path(full_name, found)
      else
        found << full_name
      end
    end
    found
  end

  def self.all_folders_in_path base, found=[]
    return [] if !File.exist? base
    Dir.foreach(base) do |each|
      next if(each == "." || each == "..")

      full_name = base + "/" +each
      if File.directory? full_name
        found << full_name
        all_folders_in_path(full_name, found)
      end
    end
    found
  end
end