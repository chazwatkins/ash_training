# Lab 2 - Relationships

## Relevant Documentation

- [Relationships](https://hexdocs.pm/ash/3.0.0-rc.21/relationships.html)

## Steps

1. We want to associate tweets to a user, so we'll add a `belongs_to :user` relationship to the `Tweet` resource:

```elixir
belongs_to :user, Twitter.Accounts.User do
  allow_nil? false
end
```

2. Don't forget the tasks you need to run to update the database! You may need to remove any existing tweets. Easiest way is to do a reset with `mix ash.reset`

3. Then we can add `:user_id` to the `accept` list for the `:create` action.

4. Next we'll add the following code to `create` block of our `"save"` handler in `form_component.exs` (above the `Changeset.for_create` code). This will set the `:user_id` attribute to the current user's id when creating a tweet, by modifying the params.

We'll use `Map.put` to put the user_id in the tweet's params (for now).

```elixir
params = put_in(params, ["tweet", "user_id"], socket.assigns.current_user.id)
```

5. Now we can show the `email` of the user who created the tweet in the tweet list. At the top of the module in `index.ex`, add a module attribute called `@tweet_loads` containing the path to the data we want to load.

```elixir
@tweet_loads [user: [:email]]
```

6. Then, alter our calls to `Ash.read!` and `Ash.get!` to include the `load` option. `load: @tweet_loads`.

7. When a tweet is saved, the form component sends a message to the parent LiveView. You can see how we react to this in `handle_info`, where we add the new tweet to the LiveView's state.

Lets update it to load the required data when a tweet is saved.

```elixir
@impl true
def handle_info({TwitterWeb.TweetLive.FormComponent, {:saved, tweet}}, socket) do
  # Add this next line
  tweet = Ash.load!(tweet, @tweet_loads, actor: socket.assigns.current_user)
  {:noreply, stream_insert(socket, :tweets, tweet)}
end
```

8. Now we can show the email in a table column:

```elixir
<:col :let={{_id, tweet}} label="Author">
  <%= tweet.user.email %>
</:col>
```

9. To track when a tweet has been liked, we'll add a `Twitter.Tweets.Like` resource. We'll store it in a table called `"likes"`, and it will have just a primary key. Let's add a default `:read` action as well, with `defaults [:read]`. Don't forget to add it to the `Tweets` domain!

10. We'll add two relationships to the `Like` resource. First, we'll add a `belongs_to :tweet` relationship. This is the tweet that you are liking. We want to set `allow_nil?` to `false` here as well.

```elixir
relationships do
  belongs_to :tweet, Twitter.Tweets.Tweet do
    allow_nil? false
  end
end
```

11. Then, do the same with the `:user` relationship, except the destination of the relationship will be `Twitter.Accounts.User`.

12. Finally, we'll add the relationship to the `Tweet` resource, using `has_many`. The `allow_nil?` option does not apply in this case, because that option is not supported for `has_many` (and it is okay if a tweet has no likes anyway).

13. Now, we'll add a (temporary) `:create` action to `Like` to allow us to play with the relationships.

```elixir
create :create do
  accept [:tweet_id, :user_id]
end
```

## Try on your own

- Create a like for a tweet in `iex -S mix`, like so:

```elixir
iex> tweet_id = Ash.first!(Twitter.Tweets.Tweet, :id)
iex> user_id = Ash.first!(Twitter.Accounts.User, :id)
iex> Twitter.Tweets.Like
     |> Ash.Changeset.for_create(:create, %{tweet_id: tweet_id, user_id: user_id})
     |> Ash.create!()
```

- Then try loading related likes for a tweet!

```elixir
iex> Twitter.Tweets.Tweet
     |> Ash.Query.load(:likes)
     |> Ash.read!()
```


- Generate resource diagrams with `mix ash.generate_resource_diagrams --format png` (requires `npm install -g @mermaid-js/mermaid-cli`, if you have issues)

- Show the `user.id` in the tweet list in the same way we're showing the `user.email`.

- In `iex`, list all of the users, and load their tweets.

- Add a `dislikes` relationship, and a resource for tracking `dislikes`.
