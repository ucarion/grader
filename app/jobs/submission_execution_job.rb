class SubmissionExecutionJob
  attr_reader :submission

  def initialize(submission_id)
    @submission = Submission.find(submission_id)
  end

  def perform
    execute_submission_code
  end

  private

  def execute_submission_code
    assignment = submission.assignment
    language = assignment.course.language

    # Add the files into the image
    files = submission.source_files.map { |file| file.code.path }

    image = docker_image.insert_local('localPath' => files,
      'outputPath' => '/', 'rm' => true)

    # Now, let's generate an image that will run the submission
    cmd = [ "/bin/bash", "-c",
      cmd_for(language, submission.main_file, assignment.input) ]

    # Run and get output
    container = image.run(cmd)

    # It would appear that setting
    #
    #    logs: true
    #
    # Will make sure that Docker always returns some kind of output. Why this
    # would be the case is beyond me.
    messages = container.attach(logs: true)

    stdout = messages[0].join
    stderr = messages[1].join
    output = stdout + stderr

    submission.update_attributes(output: output)

    status = if outputs_equal?(assignment.expected_output, output)
      Submission::Status::OUTPUT_CORRECT
    else
      Submission::Status::OUTPUT_INCORRECT
    end

    submission.update_attributes(status: status)

    # Cleanup
    container.delete
    image.remove
  end

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

  def outputs_equal?(expected, actual)
    cleanup_output(expected) == cleanup_output(actual)
  end

  def cleanup_output(output)
    output.gsub("\r", "").strip
  end
end
