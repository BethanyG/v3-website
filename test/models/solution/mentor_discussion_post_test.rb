require 'test_helper'

class Iteration::DiscussionPostTest < ActiveSupport::TestCase
  include MarkdownFieldMatchers

  test "generates uuid" do
    post = create :solution_mentor_discussion_post

    assert post.uuid.present?
  end

  test "has markdown fields for feedback" do
    assert_markdown_field(:solution_mentor_discussion_post, :content)
  end

  test "validates content markdown" do
    post = build :solution_mentor_discussion_post
    assert post.valid?

    post.content_markdown = " "
    refute post.valid?
  end

  test "#by_student? returns true if post from student" do
    student = create :user
    solution = create :concept_solution, user: student
    discussion = create :solution_mentor_discussion, solution: solution
    post = create :solution_mentor_discussion_post, discussion: discussion, author: student

    assert post.by_student?
  end

  test "#by_student? returns false if post from mentor" do
    mentor = create :user
    discussion = create :solution_mentor_discussion, mentor: mentor
    post = create :solution_mentor_discussion_post, discussion: discussion, author: mentor

    refute post.by_student?
  end

  test "#to_param returns uuid" do
    post = create :solution_mentor_discussion_post

    assert_equal post.uuid, post.to_param
  end
end
