class CreateSubmissionTestRuns < ActiveRecord::Migration[6.0]
  def change
    create_table :submission_test_runs do |t|
      t.belongs_to :submission, foreign_key: true, null: false
      t.string :tooling_job_id, null: false

      t.string :status, null: false
      t.text :message, null: true
      t.json :tests, null: true

      t.integer :ops_status, limit: 2, null: false

      t.json :raw_results, null: false

      t.timestamps
    end
  end
end
