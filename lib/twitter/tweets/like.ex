defmodule Twitter.Tweets.Like do
  @moduledoc false
  use Ash.Resource,
    otp_app: :twitter,
    domain: Twitter.Tweets,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "likes"
    repo Twitter.Repo

    references do
      reference :tweet, on_delete: :delete
    end
  end

  actions do
    defaults [:read, :destroy]

    create :like do
      accept [:tweet_id]
      change set_attribute(:type, :like)
      upsert? true
      upsert_identity :unique_user_tweet
    end

    create :dislike do
      accept [:tweet_id]
      change set_attribute(:type, :dislike)
      upsert? true
      upsert_identity :unique_user_tweet
    end

    destroy :unlike do
      argument :tweet_id, :uuid, allow_nil?: false
      change filter expr(tweet_id == ^arg(:tweet_id) and user_id == ^actor(:id))
    end
  end

  changes do
    change relate_actor(:user)
  end

  attributes do
    uuid_primary_key :id

    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:like, :dislike]
    end
  end

  relationships do
    belongs_to :tweet, Twitter.Tweets.Tweet do
      allow_nil? false
    end

    belongs_to :user, Twitter.Accounts.User do
      allow_nil? false
    end
  end

  identities do
    identity :unique_user_tweet, [:user_id, :tweet_id]
  end
end
