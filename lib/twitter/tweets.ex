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
    resource __MODULE__.Tweet do
      define :get_tweet, action: :read, get_by: [:id]
      define :feed
      define :popular_tweets
      define :create_tweet, action: :create
      define :update_tweet, action: :update
      define :delete_tweet, action: :destroy
    end

    resource __MODULE__.Like do
      define :like_tweet, action: :like, args: [:tweet_id]
      define :dislike_tweet, action: :dislike, args: [:tweet_id]
      define :unlike_tweet, action: :unlike, args: [:tweet_id], require_reference?: false
    end
  end
end
