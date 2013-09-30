module PlagiarismHelper
  REPORTABLE_SCORE = 0.9

  def find_and_report_plagiarism!(assignment)
    assignment.submissions.each do |sub1|
      assignment.submissions.each do |sub2|
        next if sub1 == sub2

        source1 = File.read(sub1.main_file.code.path)
        source2 = File.read(sub2.main_file.code.path)

        distance = DamerauLevenshtein.distance(source1, source2)
        plagiarism_score = 1 - distance.to_f / [ source1.length, source2.length ].max

        logger.debug "Encountered a score of: #{plagiarism_score}"

        sub1.plagiarizing << sub2.id if plagiarism_score > REPORTABLE_SCORE
        sub1.save!
      end
    end
  end
end
