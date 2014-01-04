module PathHelper
  def get_path(path_mode, var)
    path_mode == :absolute ? File.absolute_path(var) : var
  end
end