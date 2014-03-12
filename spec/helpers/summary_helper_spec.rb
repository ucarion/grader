require 'spec_helper'

describe SummaryHelper do
  it "gives the first paragraph" do
    msg = <<-EOF
      Hi there.

      More messages go here. These should be ignored.
    EOF

    helper.summarize(msg).should eq "Hi there."
  end

  it "limits the length of the result" do
    long_msg = "a" * 100
    shortened = "a" * 15 + " ..."
    helper.summarize(long_msg, max_length: 15).should eq shortened
  end

  it "gets the html text generated" do
    msg = <<-EOF
      A [link](example.com)
    EOF

    helper.summarize(msg).should eq "A link"
  end

  it "works fine with an empty string" do
    helper.summarize("").should eq ""
  end
end
