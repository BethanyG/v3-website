require 'test_helper'

class Solution::MentorDiscussion::ReplyByMentorTest < ActiveSupport::TestCase
  test "creates discussion post" do
    iteration = create :iteration
    content_markdown = "foobar"
    mentor = create :user
    discussion = create :solution_mentor_discussion, mentor: mentor, solution: iteration.solution

    discussion_post = Solution::MentorDiscussion::ReplyByMentor.(
      discussion,
      iteration,
      content_markdown
    )
    assert discussion_post.persisted?
    assert_equal iteration, discussion_post.iteration
    assert_equal discussion, discussion_post.discussion
    assert_equal content_markdown, discussion_post.content_markdown
    assert_equal mentor, discussion_post.author
    assert discussion_post.seen_by_mentor?
    refute discussion_post.seen_by_student?
  end

  test "creates notification" do
    user = create :user
    solution = create :practice_solution, user: user
    iteration = create :iteration, solution: solution
    discussion = create(:solution_mentor_discussion, solution: solution)

    Solution::MentorDiscussion::ReplyByMentor.(
      discussion,
      iteration,
      "foobar"
    )
    assert_equal 1, user.notifications.size
    notification = User::Notification.where(user: user).first
    assert_equal User::Notifications::MentorRepliedToDiscussionNotification, notification.class
    assert_equal(
      { discussion_post: Solution::MentorDiscussionPost.first.to_global_id.to_s }.with_indifferent_access,
      notification.send(:params)
    )
  end
end
