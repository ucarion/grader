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

  def execute_submission(submission)
    language = submission.assignment.course.language

    image = docker_image
    file_name = source_code_file_name
    source = File.read(source_code.path).shellescape
    input = assignment.input.shellescape

    cmd = [ "/bin/bash", "-c", cmd_for(language, source, file_name, input) ]

    container = image.run(cmd)
    output = container.attach(stderr: true)

    update_attributes(output: output)

    if output.strip == assignment.expected_output.strip
      update_attributes(status: Submission::Status::OUTPUT_CORRECT)
    else
      update_attributes(status: Submission::Status::OUTPUT_INCORRECT)
    end

    container.delete
  end

  private

  DOCKER_IMAGE_ID = '3d18420281f8'

  def cmd_for(language, source, file_name, input)
    file_name_no_ext = file_name.split(".").first

    case language
    when Language::Ruby
      "echo #{source} > #{file_name}; echo #{input} | ruby #{file_name}"
    when Language::Java
      "echo #{source} > #{file_name}; javac #{file_name} && echo #{input} | java #{file_name_no_ext}"
    when Language::C
      "echo #{source} > #{file_name}; gcc #{file_name} && echo #{input} | ./a.out"
    when Language::Cpp
      "echo #{source} > #{file_name}; g++ #{file_name}; echo #{input} | ./a.out"
    when Language::Python
      "echo #{source} > #{file_name}; echo #{input} | python #{file_name}"
    end
  end

  def docker_image
    Docker::Image.all.each do |image|
      return image if image.id.starts_with?(DOCKER_IMAGE_ID)
    end
  end
end
