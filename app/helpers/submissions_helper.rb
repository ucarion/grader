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

    # Add the submission's files into the image
    submission_files = submission.source_files.map { |file| file.code.path }

    image = docker_image.insert_local('localPath' => submission_files, 'outputPath' => '/')

    # Next, find the main source file
    main = submission.source_files.find { |file| file.main? }

    # Now, let's generate an image that will run the submission
    cmd = [ "/bin/bash", "-c", cmd_for(language, main, assignment.input) ]

    # Run and get output
    container = image.run(cmd)
    output = container.attach(stderr: true)

    update_attributes(output: output)

    if output.strip == assignment.expected_output.strip
      update_attributes(status: Submission::Status::OUTPUT_CORRECT)
    else
      update_attributes(status: Submission::Status::OUTPUT_INCORRECT)
    end

    # Cleanup
    container.delete
    image.remove
  end

  private

  DOCKER_IMAGE_ID = '3d18420281f8'

  def cmd_for(language, main, input)
    file_name = main.code_file_name
    file_name_no_ext = file_name.split(".").first

    case language
    when Language::Ruby
      "echo #{input} | ruby #{file_name}"
    when Language::Python
      "echo #{input} | python #{file_name}"
    when Language::Java
      "javac *.java && echo #{input} | java #{file_name_no_ext}"
    when Language::C
      "gcc *.c && echo #{input} | ./a.out"
    when Language::Cpp
      "g++ *.cpp && echo #{input} | ./a.out"
    end
  end

  def docker_image
    Docker::Image.all.find { |image| image.id.starts_with?(DOCKER_IMAGE_ID) }
  end
end
