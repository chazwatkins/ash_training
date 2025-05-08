defmodule Twitter.Tweets.Tweet do
  @moduledoc false
  use Ash.Resource,
    otp_app: :twitter,
    domain: Twitter.Tweets,
    data_layer: AshPostgres.DataLayer

  alias Twitter.Tweets.Like

  actions do
    defaults [:read, :destroy]

    read :feed do
      prepare build(sort: [inserted_at: :desc])
    end

    create :create do
      primary? true
      accept [:text, :label]
      change relate_actor(:user)
    end

    update :update do
      primary? true
      accept [:text, :label, :user_id]
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
end
