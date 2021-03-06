class PracticeExercise
  class Create
    include Mandate

    initialize_with :uuid, :track, :attributes

    def call
      PracticeExercise.create_or_find_by!(uuid: uuid, track: track) do |pe|
        pe.attributes = attributes
      end
    end
  end
end
