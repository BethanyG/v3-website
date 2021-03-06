require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/websockets_helpers"

module Flows
  class UserLoadsNotificationsTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include WebsocketsHelpers

    test "user views notifications" do
      user = create :user
      mentor = create :user, handle: "mr-mentor"
      discussion = create :solution_mentor_discussion, mentor: mentor
      create :mentor_started_discussion_notification, user: user, params: { discussion: discussion }

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        within(".c-notification") { assert_text "1" }
        find(".c-notification").click

        assert_text "mr-mentor has started mentoring your solution to Bob in Ruby"
        assert_link "See all your notifications", href: notifications_url
      end
    end

    test "refetches on websocket notification" do
      user = create :user
      mentor = create :user, handle: "mrs-mentor"
      discussion = create :solution_mentor_discussion, mentor: mentor

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        wait_for_websockets

        create :mentor_started_discussion_notification, user: user, params: { discussion: discussion }

        NotificationsChannel.broadcast_changed(user)
        within(".c-notification") { assert_text "1" }
        find(".c-notification").click

        assert_text "mrs-mentor has started mentoring your solution to Bob in Ruby"
      end
    end

    test "user views unrevealed badges" do
      user = create :user
      badge = create :rookie_badge
      create :user_acquired_badge, user: user, badge: badge, revealed: false

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        find(".c-notification").click

        assert_link "You've earned a new badge", href: badges_journey_url
      end
    end
  end
end
