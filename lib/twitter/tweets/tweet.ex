defmodule Twitter.Tweets.Tweet do
  @moduledoc false
  use Ash.Resource,
    otp_app: :twitter,
    domain: Twitter.Tweets,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  alias Twitter.Tweets.Like

  actions do
    defaults [:read, :destroy]

    read :feed do
      prepare build(sort: [inserted_at: :desc])
    end

    read :popular_tweets do
      prepare build(sort: [like_count: :desc], limit: 10)
    end

    create :create do
      primary? true
      accept [:text, :label, :private]
      change relate_actor(:user)
    end

    update :update do
      primary? true
      accept [:text, :label, :user_id, :private]
    end
  end

  validations do
    validate string_length(:text, max: 255)
  end

  attributes do
    uuid_primary_key :id

    attribute :text, :string do
      allow_nil? false
    end

    attribute :private, :boolean do
      default false
    end

    attribute :label, :string

    timestamps()
  end

  relationships do
    belongs_to :user, Twitter.Accounts.User do
      allow_nil? false
    end

    has_many :likes, Like
  end

  aggregates do
    count :like_count, :likes do
      filter expr(type == :like)
    end

    count :dislike_count, :likes do
      filter expr(type == :dislike)
    end

    first :user_email, :user, :email do
      authorize? false
    end
  end

  calculations do
    calculate :text_length, :integer, expr(string_length(text))

    calculate :liked_by_me,
              :boolean,
              expr(
                exists(
                  likes,
                  user_id == ^actor(:id) and type == :like
                )
              )

    calculate :disliked_by_me,
              :boolean,
              expr(
                exists(
                  likes,
                  user_id == ^actor(:id) and type == :dislike
                )
              )
  end

  postgres do
    table "tweets"
    repo Twitter.Repo
  end

  policies do
    bypass expr(user.admin == true) do
      authorize_if always()
    end

    policy expr(private == true) do
      authorize_if relating_to_actor(:user)
    end

    policy action_type(:read) do
      forbid_if expr(user.disabled == true)
      authorize_if expr(private == false)
    end

    policy action(:create) do
      authorize_if always()
    end

    policy action([:update, :destroy]) do
      authorize_if expr(user_id == ^actor(:id))
    end
  end
end
