# Lab 5 - Aggregates

## Relevant Documentation

- [Aggregates](https://hexdocs.pm/ash/aggregates.html)

## Steps

1. We want to see how many likes a tweet has. We can do this by adding an
   aggregate to the tweet resource. Add the following aggregate to `Twitter.Tweets.Tweet`.

```elixir
count :like_count, :likes
```

2. Now we can add `:like_count` to our `@tweet_loads` in `index.ex`, and then display it next to the heart icon.

```elixir
@tweet_loads [:text_length, :liked_by_me, :like_count, user: [:email]]
```

```elixir
<:action :let={{_id, tweet}}>
  <%= if tweet.liked_by_me do %>
    <button phx-click="unlike" phx-value-id={tweet.id}>
      <.icon name="hero-heart-solid" class="text-red-600" />
    </button>
  <% else %>
    <button phx-click="like" phx-value-id={tweet.id}>
      <.icon name="hero-heart" />
    </button>
  <% end %>

  # Add the line below
  <%= tweet.like_count %>
</:action>
```

3. So far in our application, for showing the user's email, we have been loading the user for
   each tweet (we have `user: [:email]` in `@tweet_loads`).

We can use the `first` aggregate for this. Not only is this more efficient, but it will also
make the next section on policies simpler.

```elixir
first :user_email, :user, :email
```

4. Then, replace `user: [:email]` from `@tweet_loads` with `:user_email`, and update `index.ex` to show it:

```elixir
@tweet_loads [:text_length, :liked_by_me, :like_count, :user_email]
```

```elixir
<:col :let={{_id, tweet}} label="Author">
  <%= tweet.user_email %>
</:col>
```

Now, we only make a single query when fetching the tweet, instead of two! (One for the tweet, and one for the user.) You can see the modified sql query in the logs.

## Try on your own

- Add a `first` aggregate to get the "email of the user who most recently liked the tweet"
- Add a `list` aggregate to get the "emails of all users who liked the tweet"
- Add a `max` aggregate to users to get the "amount of likes on their most liked tweet"
