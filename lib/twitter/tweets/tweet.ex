defmodule Twitter.Tweets.Tweet do
  @moduledoc false
  use Ash.Resource,
    otp_app: :twitter,
    domain: Twitter.Tweets,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:read, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :text, :string do
      allow_nil? false
    end

    timestamps()
  end

  postgres do
    table "tweets"
    repo Twitter.Repo
  end
end
