require 'spec_helper'

describe "Static pages" do
  describe "Home page" do
    it "should have the content 'Grader'" do
      visit '/static_pages/home'
      expect(page).to have_content('Grader')
    end

    it "should have 'Home' in the title" do
      visit '/static_pages/home'
      expect(page).to have_title('Grader | Home')
    end
  end

  describe "Help page" do
    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end

    it "should have 'Help' in the title" do
      visit '/static_pages/help'
      expect(page).to have_title('Grader | Help')
    end
  end

  describe "About page" do
    it "should have the content 'About'" do
      visit '/static_pages/about'
      expect(page).to have_content('About')
    end

    it "should have 'About' in the title" do
      visit '/static_pages/about'
      expect(page).to have_title('Grader | About')
    end
  end
end
