# Lab 4 - Calculations

## Relevant Documentation

- [Calculations](https://hexdocs.pm/ash/calculations.html)
- [Expressions](https://hexdocs.pm/ash/expressions.html)

## Steps

We want to display two things about a tweet in the UI.

- How many characters it has
- Whether or not the current user has liked it.

We will get into "how many likes does it have" in the next section on aggregates.

1. Let's add a calculation to the tweet resource to calculate the length of the text.

```elixir
calculate :text_length, :integer, expr(string_length(text))
```

2. Now, update `@tweet_loads` in `index.ex` like so:

```elixir
@tweet_loads [:text_length, user: [:email]]
```

3. And add a column to our table to show the length

```elixir
<:col :let={{_id, tweet}} label="Length">
  <%= tweet.text_length %>
</:col>
```

4. Now we want to show if the current user has liked the tweet.

```elixir
calculate :liked_by_me, :boolean, expr(exists(likes, user_id == ^actor(:id)))
```

5. Now, lets replace our like and unlike buttons with a heart icon.
   Add `:liked_by_me` to `@tweet_loads`.

```elixir
@tweet_loads [:text_length, :liked_by_me, user: [:email]]
```

We will use this calculation to conditionally make the heart icon red.

Replace the like and unlike button actions with the following:

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
</:action>
```

Now you can like and unlike in one click!

## Try on your own

- Use a module calculation to calculate the text length
- Use a module calculation to calculate the ratio of likes per character of text
- Use an expression calculation to calculate likes per character
