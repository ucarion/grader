module SubmissionsHelper
  def table_class_for_status(status)
    case status
    when Submission::Status::WAITING
      ""
    when Submission::Status::OUTPUT_CORRECT
      "success"
    when Submission::Status::OUTPUT_INCORRECT
      "error"
    end
  end

  def status_label(submission)
    color, text = "", ""
    case submission.status
    when Submission::Status::WAITING
      color, text = "default", "Waiting"
    when Submission::Status::OUTPUT_CORRECT
      color, text = "success", "Tests passed"
    when Submission::Status::OUTPUT_INCORRECT
      color, text = "danger", "Tests failed"
    end

    content_tag(:label, text, class: "label label-#{color}")
  end

  def highlighted_code(submission, code)
    Pygments.highlight(code, lexer: submission.assignment.course.language)
  end

  private

  def cmd_for(language, main, input)
    input = input.shellescape

    file_name = main.code_file_name
    file_name_no_ext = file_name.split(".").first

    cmd = case language
    when Language::Ruby
      "echo #{input} | ruby #{file_name}"
    when Language::Python
      "echo #{input} | python #{file_name}"
    when Language::Java
      klass_name = java_package(main) + file_name_no_ext

      java_cmd(klass_name, input)
    when Language::C
      "gcc *.c && echo #{input} | ./a.out"
    when Language::Cpp
      "g++ *.cpp && echo #{input} | ./a.out"
    end

    cmd
  end

  def java_package(main_file)
    source_code = File.read(main_file.code.path)

    package_line = source_code.split(/\n/).find do |line|
      line.starts_with?('package')
    end

    package = if package_line
      package_line.split(/[ ;]/).last.gsub(/[^0-9a-z \.]/i, '') + "."
    else
      ""
    end
  end

  def java_cmd(klass_name, input)
    "mkdir submission_bin;" +
      "javac -d submission_bin/ *.java && " +
      "echo #{input} | " +
      "java -Xbootclasspath/p:java-overrides -cp submission_bin/ #{klass_name}"
  end

  def docker_image
    Docker::Image.all.find { |img| img.info['Repository'] == 'ulysse/polyglot' }
  end
end
