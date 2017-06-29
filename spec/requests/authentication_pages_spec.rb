require 'spec_helper'

describe "Authentication", type: :request do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { first(:button, "Sign in").click }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert') }
      it { should have_selector('div.alert-danger') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert-danger') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      #it { should have_title(user.name) } # Switched signin redirect to go to home page rather than user's profile
      it { should have_link('Users',       href: users_path) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Settings',    href: edit_user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
        it { should_not have_link('Profile') }
        it { should_not have_link('Settings') }
      end
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          sign_in user
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_title('Sign in') }
        end
      end

      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe "in the UserUserRelationships controller" do
        describe "submitting to the create action" do
          before { post user_user_relationships_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete user_user_relationship_path(1) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

=begin
      describe "in the Makes controller" do
        describe "submitting to the create action" do
          before { post makes_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting a GET request to the Makes#edit action" do
          before { get edit_make_path }
          specify { expect(response.body).not_to match(full_title('Edit make')) }
          specify { expect(response).to redirect_to(root_url) }
        end

        describe "submitting to the destroy action" do
          before { delete make_path(FactoryGirl.create(:make)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
=end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a GET request to the Users#new action" do
        before { get new_user_path }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a POST request to the Users#create action" do
        before { post users_path }
        specify { expect(response).to redirect_to(root_url) }
      end

    end

    describe "as admin user" do
      let(:admin) { FactoryGirl.create(:admin) }

      before { sign_in admin, no_capybara: true }

      describe "submitting a DELETE request to the Users#destroy action on himself" do
        before { delete user_path(admin) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
  end

end