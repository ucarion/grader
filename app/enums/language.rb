class Language < ClassyEnum::Base
  def bad_filetype_message
    "Only upload your *.#{file_extension} files."
  end
end

class Language::C < Language
  def file_extension
    "c, h"
  end
end

class Language::Cpp < Language
  def file_extension
    "cpp, hpp"
  end
end

class Language::Java < Language
  def file_extension
    "java"
  end
end

class Language::Ruby < Language
  def file_extension
    "rb"
  end
end

class Language::Python < Language
  def file_extension
    "py"
  end
end
