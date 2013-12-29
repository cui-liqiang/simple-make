class DirTraverser
  def self.all_files_in_absolute_path base, found=[]
    Dir.foreach(base) do |each|
      next if(each == "." || each == "..")

      full_name = base + "/" +each
      if File.directory? full_name
        all_files_in_absolute_path(full_name, found)
      else
        found << full_name
      end
    end
    found
  end
end