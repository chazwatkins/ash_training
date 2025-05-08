defmodule Twitter.Tweets do
  @moduledoc false
  use Ash.Domain,
    extensions: [AshJsonApi.Domain, AshAdmin.Domain]

  admin do
    show? true
  end

  json_api do
    prefix "/api/json"
  end

  resources do
    resource Twitter.Tweets.Tweet do
      define :get_tweet, action: :read, get_by: [:id]
      define :list_tweets, action: :read
      define :create_tweet, action: :create
      define :update_tweet, action: :update
      define :delete_tweet, action: :destroy
    end
  end
end
