class CreateUserTrackMentorships < ActiveRecord::Migration[6.1]
  def change
    create_table :user_track_mentorships do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :track, null: false, foreign_key: true

      t.index [:user_id, :track_id], unique: true

      t.timestamps
    end
  end
end
