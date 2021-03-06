FactoryBot.define do
  factory :user_code_contribution_reputation_token, class: 'User::ReputationTokens::CodeContributionToken' do
    user
    level { :regular }

    params do
      {
        repo: "exercism/ruby",
        pr_node_id: SecureRandom.uuid,
        pr_number: SecureRandom.random_number(100_000),
        pr_title: "The cat sat on the mat"
      }
    end
  end

  factory :user_code_merge_reputation_token, class: 'User::ReputationTokens::CodeMergeToken' do
    user
    level { :janitorial }

    params do
      {
        repo: "exercism/ruby",
        pr_node_id: SecureRandom.uuid,
        pr_number: SecureRandom.random_number(100_000),
        pr_title: "The cat sat on the mat"
      }
    end
  end

  factory :user_code_review_reputation_token, class: 'User::ReputationTokens::CodeReviewToken' do
    user
    level { :regular }

    params do
      {
        repo: "exercism/ruby",
        pr_node_id: SecureRandom.uuid,
        pr_number: SecureRandom.random_number(100_000),
        pr_title: "The cat sat on the mat"
      }
    end
  end

  factory :user_exercise_contribution_reputation_token, class: 'User::ReputationTokens::ExerciseContributionToken' do
    user

    params do
      {
        contributorship: create(:exercise_contributorship, contributor: user)
      }
    end
  end

  factory :user_exercise_author_reputation_token, class: 'User::ReputationTokens::ExerciseAuthorToken' do
    user

    params do
      {
        authorship: create(:exercise_authorship, author: user)
      }
    end
  end
end
