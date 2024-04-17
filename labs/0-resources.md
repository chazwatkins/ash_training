# Lab 0 - Resources

## Relevant Documentation

- [Getting Started](https://hexdocs.pm/ash/3.0.0-rc.21/get-started.html)
- [Attributes](https://hexdocs.pm/ash/3.0.0-rc.21/attributes.html)
- [Domains](https://hexdocs.pm/ash/3.0.0-rc.21/domains.html)
- [Ash.Resource.Info](https://hexdocs.pm/ash/3.0.0-rc.21/Ash.Resource.Info.html)
- [Ash.Domain.Info](https://hexdocs.pm/ash/3.0.0-rc.21/Ash.Domain.Info.html)
- [AshPostgres.DataLayer.Info](https://hexdocs.pm/ash_postgres/2.0.0-rc.7/AshPostgres.DataLayer.Info.html)

## Steps

1. Define the `Twitter.Tweets.Tweet` resource in `lib/twitter/tweets/tweet.ex`

2. Add a `uuid_primary_key` attribute.

3. Add `defaults [:read]` to the `actions` block.

4. Run `iex -S mix`, and use functions from `Ash.Resource.Info` to see that we've defined the resource properly. (ignore the warnings presented in iex)

```elixir
iex> Ash.Resource.Info.attributes(Twitter.Tweets.Tweet)
# [%Ash.Resource.Attribute{}]
```

```elixir
iex> Ash.Resource.Info.actions(Twitter.Tweets.Tweet)
# [%Ash.Resource.Read{}]
```

5. Add `Twitter.Tweets.Tweet` to our domain module's resource list. Ignore the extra content in the domain for module for now.

6. Then, go to our `Tweet` resource, and configure it to use the `Twitter.Tweets` domain:

```elixir
use Ash.Resource,
  domain: Twitter.Tweets
```

7. Use functions from `Ash.Domain.Info`

```elixir
iex> Ash.Domain.Info.resources(Twitter.Tweets)
# [...]
```

8. Make the `Tweet` resource use `AshPostgres.DataLayer`, and configure it to use the `"tweets"` table, and the `Twitter.Repo` repo. We can check our configuration with `AshPostgres.DataLayer.Info`

```elixir
iex> AshPostgres.DataLayer.Info.table(Twitter.Tweets.Tweet)
# "tweets"
```

```elixir
iex> AshPostgres.DataLayer.Info.repo(Twitter.Tweets.Tweet)
# Twitter.Repo
```

9. To check out the whole data structure for a resource, do this in `iex -S mix`. We remove some housekeeping metadata.

```elixir
iex> Twitter.Tweets.Tweet.spark_dsl_config() |> Map.delete(:persist)
```

## Try on your own

- Add a `:text` attribute to the `Tweet` resource, and check the attributes list again.

- Change the table name to something else, and check the table name again.

- Make your own resource, adding it to the Tweets domain. See it show up in the domain's resources list.
