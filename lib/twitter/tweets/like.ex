defmodule Twitter.Tweets.Like do
  use Ash.Resource,
    domain: Twitter.Tweets,
    data_layer: AshPostgres.DataLayer

  require Ash.Query

  postgres do
    table "likes"
    repo Twitter.Repo

    references do
      reference :tweet, on_delete: :delete
    end
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :user, Twitter.Accounts.User do
      allow_nil? false
    end

    belongs_to :tweet, Twitter.Tweets.Tweet do
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]

    create :like do
      upsert? true
      upsert_identity :unique_user_tweet
      accept [:tweet_id]
      change relate_actor(:user)
    end

    destroy :unlike do
      argument :tweet_id, :uuid, allow_nil?: false
      change filter(expr(tweet_id == ^arg(:tweet_id) and user_id == ^actor(:id)))
    end
  end

  identities do
    identity :unique_user_tweet, [:user_id, :tweet_id]
  end
end
