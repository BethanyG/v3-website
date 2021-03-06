require 'test_helper'

class ToolingJob::ProcessTest < ActiveSupport::TestCase
  test "retry looking up the job 4 times" do
    id = SecureRandom.uuid
    cmd = ToolingJob::Process.new(id)
    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      cmd.expects(:sleep).with(0.5).times(4)
    end
    ToolingJob.expects(:find).with(id, full: true, strongly_consistent: true).times(5).raises(StandardError)

    assert_raises do
      cmd.()
    end
  end

  test "proxies to test run" do
    submission = create :submission
    execution_status = "job-status"
    results = { 'some' => 'result' }
    job = create_test_runner_job!(
      submission,
      execution_status: execution_status,
      results: results
    )

    Submission::TestRun::Process.expects(:call).with(job)

    ToolingJob::Process.(job.id)
  end

  test "proxies to representer" do
    id = SecureRandom.uuid
    type = "representer"
    submission = create :submission
    execution_status = "job-status"
    representation_contents = "some\nrepresentation"
    mapping_contents = { 'foo' => 'bar' }

    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "submission_uuid" => submission.uuid,
        "execution_status" => execution_status,
        "execution_output" => {
          "representation.txt" => representation_contents,
          "mapping.json" => mapping_contents.to_json
        }
      }
    )

    job = create_representer_job!(
      submission,
      execution_status: execution_status,
      ast: representation_contents,
      mapping: mapping_contents
    )

    Submission::Representation::Process.expects(:call).with(job)
    ToolingJob::Process.(job.id)
  end

  test "proxies to analyzer" do
    id = SecureRandom.uuid
    type = "analyzer"
    submission = create :submission
    execution_status = "job-status"
    analysis = { 'some' => 'result' }

    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "submission_uuid" => submission.uuid,
        "execution_status" => execution_status,
        "execution_output" => { "analysis.json" => analysis.to_json }
      }
    )

    job = create_analyzer_job!(
      submission,
      execution_status: execution_status,
      data: analysis
    )

    Submission::Analysis::Process.expects(:call).with(job)
    ToolingJob::Process.(job.id)
  end

  test "sets dynamodb job status to processed" do
    id = SecureRandom.uuid
    type = "analyzer"
    submission = create :submission
    execution_status = "job-status"
    analysis = { 'some' => 'result' }

    write_to_dynamodb(
      Exercism.config.dynamodb_tooling_jobs_table,
      {
        "id" => id,
        "type" => type,
        "submission_uuid" => submission.uuid,
        "execution_status" => execution_status,
        "execution_output" => { "analysis.json" => analysis.to_json }
      }
    )

    ToolingJob::Process.(id)

    assert_equal "processed", ToolingJob.find(id).job_status
  end
end
