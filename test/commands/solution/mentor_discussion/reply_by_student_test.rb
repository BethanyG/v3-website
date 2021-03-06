require 'test_helper'

class Solution::MentorDiscussion::ReplyByStudentTest < ActiveSupport::TestCase
  test "creates discussion post" do
    iteration = create :iteration
    content_markdown = "foobar"
    discussion = create :solution_mentor_discussion, solution: iteration.solution

    discussion_post = Solution::MentorDiscussion::ReplyByStudent.(
      discussion,
      iteration,
      content_markdown
    )
    assert discussion_post.persisted?
    assert_equal iteration, discussion_post.iteration
    assert_equal discussion, discussion_post.discussion
    assert_equal content_markdown, discussion_post.content_markdown
    assert_equal iteration.solution.user, discussion_post.author
    assert discussion_post.seen_by_student?
    refute discussion_post.seen_by_mentor?
  end

  test "creates notification" do
    user = create :user
    solution = create :practice_solution, user: user
    iteration = create :iteration, solution: solution
    mentor = create :user
    discussion = create(:solution_mentor_discussion, solution: solution, mentor: mentor)

    Solution::MentorDiscussion::ReplyByStudent.(
      discussion,
      iteration,
      "foobar"
    )
    assert_equal 1, mentor.notifications.size
    notification = User::Notification.where(user: mentor).first
    assert_equal User::Notifications::StudentRepliedToDiscussionNotification, notification.class
    assert_equal(
      { discussion_post: Solution::MentorDiscussionPost.first.to_global_id.to_s }.with_indifferent_access,
      notification.send(:params)
    )
  end
end
