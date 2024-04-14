# Cheat Sheet

## Run IEx

```elixir
iex -S mix
```

## Run IEx with the phoenix server

This gives youa running phoenix server and an IEx prompt.

```elixir
iex -S mix phx.server
```

## Run just the phoenix server

```elixir
mix phx.server
```

## Generate Migrations

```
mix ash.codegen <what_changed_here>
```

## Run Migrations

```
mix ash.migrate
```

## Reset the database

```
mix ash.reset
```

## IEx Cheat Sheet

### Recompile after changes

If you are running the browser application, you can refresh the browser. Otherwise:

```elixir
recompile
```
