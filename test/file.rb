class File
  def initialize(path, commit = nil, content = nil)
    @path, @commit, @content = path, commit, content
  end
end
