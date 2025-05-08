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

    timestamps()
  end

  postgres do
    table "tweets"
    repo Twitter.Repo
  end
end
