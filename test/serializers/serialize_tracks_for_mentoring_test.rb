require 'test_helper'

class Solution::MentorRequest::RetrieveTracksTest < ActiveSupport::TestCase
  test "serializes correctly" do
    user = create :user

    fsharp = create :track, slug: "fsharp", title: "F#" # Has no requests
    ruby = create :track, slug: "ruby", title: "Ruby"
    csharp = create :track, slug: "csharp", title: "C#"
    elixir = create :track, slug: "elixir", title: "Elixir" # Is not mentored

    create :user_track_mentorship, user: user, track: fsharp
    create :user_track_mentorship, user: user, track: ruby
    create :user_track_mentorship, user: user, track: csharp

    # This shouldn't be included
    strings = create :concept_exercise, track: ruby

    # These are csharp and should be included
    zipper = create :concept_exercise, track: csharp, slug: :zipper, title: "Zipper"
    bob = create :practice_exercise, track: csharp, slug: :bob, title: "Bob"
    create :practice_exercise, track: csharp, slug: :fred, title: "Fred"

    # This shouldn't be included
    elixir_exercise = create :practice_exercise, track: elixir, slug: :erik, title: "Erik"

    # Make some requests for each except fred
    3.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: strings) }
    2.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: zipper) }
    4.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: bob) }
    4.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: elixir_exercise) }

    expected = {
      tracks: [
        {
          id: "csharp",
          title: "C#",
          icon_url: csharp.icon_url,
          count: 6,
          avg_wait_time: "2 days",
          num_solutions_queued: 550,
          links: {
            exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'csharp')
          }
        },
        {
          id: "fsharp",
          title: "F#",
          icon_url: fsharp.icon_url,
          count: 0,
          avg_wait_time: "2 days",
          num_solutions_queued: 550,
          links: {
            exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'fsharp')
          }
        },
        {
          id: "ruby",
          title: "Ruby",
          icon_url: ruby.icon_url,
          count: 3,
          avg_wait_time: "2 days",
          num_solutions_queued: 550,
          links: {
            exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'ruby')
          }
        }
      ]
    }
    actual = SerializeTracksForMentoring.(user.mentored_tracks, mentor: user)
    assert_equal expected, actual
  end

  test "serializes correctly without mentor" do
    fsharp = create :track, slug: "fsharp", title: "F#" # Has no requests
    ruby = create :track, slug: "ruby", title: "Ruby"
    csharp = create :track, slug: "csharp", title: "C#"

    # This shouldn't be included
    strings = create :concept_exercise, track: ruby

    # These are csharp and should be included
    zipper = create :concept_exercise, track: csharp, slug: :zipper, title: "Zipper"
    bob = create :practice_exercise, track: csharp, slug: :bob, title: "Bob"
    create :practice_exercise, track: csharp, slug: :fred, title: "Fred"

    # Make some requests for each except fred
    3.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: strings) }
    2.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: zipper) }
    4.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: bob) }

    expected = {
      tracks: [
        {
          id: "csharp",
          title: "C#",
          icon_url: csharp.icon_url,
          count: 6,
          avg_wait_time: "2 days",
          num_solutions_queued: 550,
          links: {
            exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'csharp')
          }
        },
        {
          id: "fsharp",
          title: "F#",
          icon_url: fsharp.icon_url,
          count: 0,
          avg_wait_time: "2 days",
          num_solutions_queued: 550,
          links: {
            exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'fsharp')
          }
        },
        {
          id: "ruby",
          title: "Ruby",
          icon_url: ruby.icon_url,
          count: 3,
          avg_wait_time: "2 days",
          num_solutions_queued: 550,
          links: {
            exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'ruby')
          }
        }
      ]
    }
    actual = SerializeTracksForMentoring.(Track.all)
    assert_equal expected, actual
  end
end
