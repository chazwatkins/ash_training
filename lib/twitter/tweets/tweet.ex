defmodule Twitter.Tweets.Tweet do
  use Ash.Resource,
    domain: Twitter.Tweets,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshJsonApi.Resource, AshGraphql.Resource],
    data_layer: AshPostgres.DataLayer

  json_api do
    type "tweet"

    routes do
      base "/tweets"
      index :feed, route: "/feed"
    end
  end

  graphql do
    type :tweet

    queries do
      list :feed, :feed
    end
  end

  actions do
    defaults [:read, :destroy]

    read :feed do
      prepare build(sort: [inserted_at: :desc])
    end

    create :create do
      primary? true
      accept [:text]

      change relate_actor(:user)
    end

    update :update do
      primary? true
      accept [:text]
    end
  end

  postgres do
    table "tweets"
    repo Twitter.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :text, :string do
      allow_nil? false
      public? true
      constraints max_length: 255
    end

    timestamps public?: true
  end

  relationships do
    belongs_to :user, Twitter.Accounts.User do
      allow_nil? false
    end

    has_many :likes, Twitter.Tweets.Like
  end

  calculations do
    calculate :text_length, :integer, expr(string_length(text))
    calculate :liked_by_me, :boolean, expr(exists(likes, user_id == ^actor(:id)))
  end

  aggregates do
    first :user_email, :user, :email do
      authorize? false
      public? true
    end

    count :like_count, :likes do
      public? true
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if always()
    end

    policy action([:update, :destroy]) do
      authorize_if expr(user_id == ^actor(:id))
    end
  end
end
