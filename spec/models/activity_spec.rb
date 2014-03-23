require 'spec_helper'

describe Activity do
  let(:user) { FactoryGirl.create(:user) }
  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:course) { FactoryGirl.create(:course, teacher: teacher) }
  let(:assignment) { FactoryGirl.create(:assignment, course: course) }
  let(:submission) { FactoryGirl.create(:submission, author: user, assignment: assignment) }
  let(:comment) { FactoryGirl.create(:comment, user: user, submission: submission) }

  describe "cascading deletion" do
    describe "for users" do
      let!(:activity) { FactoryGirl.create(:activity, user: user) }

      it "deletes activities along with users" do
        expect { user.destroy }.to change(Activity, :count).by(-1)
      end
    end

    describe "for assignments" do
      let!(:activity) { FactoryGirl.create(:activity, subject: assignment) }

      it "deletes activities along with assignments" do
        expect { assignment.destroy }.to change(Activity, :count).by(-1)
      end
    end

    describe "for submissions" do
      let!(:activity) { FactoryGirl.create(:activity, subject: submission) }

      it "deletes activities along with submissions" do
        expect { assignment.destroy }.to change(Activity, :count).by(-1)
      end
    end

    describe "for comments" do
      let!(:activity) { FactoryGirl.create(:activity, subject: comment) }

      it "deletes activities along with comments" do
        expect { comment.destroy }.to change(Activity, :count).by(-1)
      end
    end
  end
end
