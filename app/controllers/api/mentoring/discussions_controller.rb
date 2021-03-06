module API
  class Mentoring::DiscussionsController < BaseController
    # TODO: Add filters
    def index
      discussions = ::Solution::MentorDiscussion::Retrieve.(
        current_user,
        page: params[:page],
        track_slug: params[:track],
        criteria: params[:criteria],
        order: params[:order]
      )

      render json: SerializePaginatedCollection.(
        discussions,
        serializer: SerializeMentorDiscussions
      )
    end

    def tracks
      track_counts = Solution::MentorDiscussion::Retrieve.(
        current_user, sorted: false, paginated: false
      ).group(:track_id).count

      tracks = Track.where(id: track_counts.keys).index_by(&:id)
      data = track_counts.map do |track_id, count|
        track = tracks[track_id]
        {
          slug: track.slug,
          title: track.title,
          icon_url: track.icon_url,
          count: count
        }
      end

      render json: [
        {
          slug: nil,
          title: 'All',
          icon_url: Track.first.icon_url,
          count: track_counts.values.sum
        }
      ].concat(data)
    end

    def create
      mentor_request = Solution::MentorRequest.find_by(uuid: params[:mentor_request_id])
      return render_404(:mentor_request_not_found) unless mentor_request

      begin
        discussion = Solution::MentorDiscussion::Create.(
          current_user,
          mentor_request,
          params[:iteration_idx],
          params[:content]
        )
      rescue SolutionLockedByAnotherMentorError
        return render_400(:mentor_request_locked)
      end

      render json: {
        discussion: {
          id: discussion.uuid,
          is_finished: discussion.finished?,
          links: {
            posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion),
            mark_as_nothing_to_do: Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_url(discussion),
            finish: Exercism::Routes.finish_api_mentoring_discussion_url(discussion)
          }
        }
      }
    end

    def mark_as_nothing_to_do
      discussion = ::Solution::MentorDiscussion.find_by(uuid: params[:id])

      return render_404(:mentor_discussion_not_found) if discussion.blank?
      return render_403(:mentor_discussion_not_accessible) unless discussion.viewable_by?(current_user)
      return render_403(:mentor_discussion_not_accessible) unless current_user == discussion.mentor

      discussion.mentor_action_not_required!

      render json: {}
    end

    # TODO: An actual implementation of this endpoint.
    # The JSON response below is what I expect for the React component.
    def finish
      discussion = current_user.mentor_discussions.find_by(uuid: params[:id])
      discussion.update!(finished_at: Time.current)
      relationship = Mentor::StudentRelationship.find_or_create_by!(mentor: discussion.mentor, student: discussion.student)

      render json: {
        discussion: {
          relationship: SerializeMentorStudentRelationship.(relationship),
          is_finished: true,
          links: {
            posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion)
          }
        }
      }
    end
  end
end
