require 'test_helper'

class Solution::MentorRequestTest < ActiveSupport::TestCase
  test "locked?" do
    # No lock
    request = create :solution_mentor_request, locked_until: nil
    refute request.locked?

    # Expired Lock
    request.update(locked_by: create(:user), locked_until: Time.current - 5.minutes)
    refute request.locked?

    # Current Lock
    request.update(locked_by: create(:user), locked_until: Time.current + 5.minutes)
    assert request.locked?
  end

  test "lockable_by?" do
    mentor = create :user

    # No lock, fulfilled
    request = create :solution_mentor_request, locked_until: nil, status: :fulfilled
    refute request.lockable_by?(mentor)

    # Cancelled
    request.update(status: :cancelled)
    refute request.lockable_by?(mentor)

    # Pending
    request.update(status: :pending)
    assert request.lockable_by?(mentor)

    # Locked by mentor
    request.update(locked_by: mentor, locked_until: Time.current + 5.minutes)
    assert request.lockable_by?(mentor)

    # Expired locked by mentor
    request.update(locked_by: mentor, locked_until: Time.current - 5.minutes)
    assert request.lockable_by?(mentor)

    # Expired lock by other user
    request.update(locked_by: create(:user), locked_until: Time.current - 5.minutes)
    assert request.lockable_by?(mentor)

    # Active lock by other user
    request.update(locked_by: create(:user), locked_until: Time.current + 5.minutes)
    refute request.lockable_by?(mentor)
  end

  test "locked and unlocked scopes" do
    unlocked = create :solution_mentor_request, locked_until: nil
    locked = create :solution_mentor_request, locked_until: Time.current + 5.minutes
    expired = create :solution_mentor_request, locked_until: Time.current - 5.minutes

    assert_equal [locked], Solution::MentorRequest.locked
    assert_equal [unlocked, expired], Solution::MentorRequest.unlocked
  end
end
