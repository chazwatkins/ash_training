defmodule Twitter.Tweets.Tweet do
  @moduledoc false
  use Ash.Resource,
    otp_app: :twitter,
    domain: Twitter.Tweets,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:read, :destroy]

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
  end

  postgres do
    table "tweets"
    repo Twitter.Repo
  end
end
