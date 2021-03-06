class Tracks::ConceptsController < ApplicationController
  before_action :use_track
  before_action :use_concepts, only: :index
  before_action :use_concept, only: %i[show tooltip start complete]

  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @concept_map_data = Track::DetermineConceptMapLayout.(@track)

    @concept_map_data[:status] =
      UserTrack::GenerateConceptStatusMapping.(@user_track)

    @concept_map_data[:exercise_counts] =
      UserTrack::GenerateConceptExerciseMapping.(@user_track)

    @num_concepts = @track.concepts.count
    @user_track ? @num_completed = @user_track.learnt_concepts.count : @num_completed = 0
  end

  def show
    @concept_exercises = @concept.concept_exercises
    @practice_exercises = @concept.practice_exercises
  end

  def tooltip
    render layout: false
  end

  private
  def use_track
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track, external_if_missing: true)
  end

  def use_concepts
    @concepts = @track.concepts
  end

  def use_concept
    @concept = @track.concepts.find(params[:id])
  end
end
