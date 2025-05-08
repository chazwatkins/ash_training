defmodule TwitterWeb.TweetLive.Index do
  @moduledoc false
  use TwitterWeb, :live_view

  alias Twitter.Tweets

  @tweet_loads [
    :like_count,
    :liked_by_me,
    :disliked_by_me,
    :dislike_count,
    :text_length,
    user: [:email]
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Tweets
      <:actions>
        <.link patch={~p"/tweets/new"}>
          <.button>New Tweet</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="tweets"
      rows={@streams.tweets}
      row_click={fn {_id, tweet} -> JS.navigate(~p"/tweets/#{tweet}") end}
    >
      <:col :let={{_id, tweet}} label="Id">
        <span class="max-w-24 text-wrap">
          <%= tweet.id %>
        </span>
      </:col>

      <:col :let={{_id, tweet}} label="Text">
        <%= tweet.text %>
      </:col>

      <:col :let={{_id, tweet}} label="Label">
        <%= tweet.label %>
      </:col>

      <:col :let={{_id, tweet}} label="Length">
        <%= tweet.text_length %>
      </:col>

      <:col :let={{_id, tweet}} label="User Email">
        <%= tweet.user.email %>
      </:col>

      <:col :let={{_id, tweet}} label="User Id">
        <%= tweet.user.id %>
      </:col>

      <:action :let={{_id, tweet}}>
        <%= if tweet.liked_by_me do %>
          <button phx-click="unlike" phx-value-id={tweet.id}>
            <.icon name="hero-hand-thumb-up-solid" />
          </button>
        <% else %>
          <button phx-click="like" phx-value-id={tweet.id}>
            <.icon name="hero-hand-thumb-up" />
          </button>
        <% end %>

        <%= tweet.like_count %>

        <%= if tweet.disliked_by_me do %>
          <button phx-click="unlike" phx-value-id={tweet.id}>
            <.icon name="hero-hand-thumb-down-solid" />
          </button>
        <% else %>
          <button phx-click="dislike" phx-value-id={tweet.id}>
            <.icon name="hero-hand-thumb-down" />
          </button>
        <% end %>

        <%= tweet.dislike_count %>

        <div class="sr-only">
          <.link navigate={~p"/tweets/#{tweet}"}>Show</.link>
        </div>

        <.link patch={~p"/tweets/#{tweet}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, tweet}}>
        <.link
          phx-click={JS.push("delete", value: %{id: tweet.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="tweet-modal" show on_cancel={JS.patch(~p"/")}>
      <.live_component
        module={TwitterWeb.TweetLive.FormComponent}
        id={(@tweet && @tweet.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        tweet={@tweet}
        patch={~p"/"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(
       socket,
       :tweets,
       Tweets.read_feed!(actor: socket.assigns.current_user, load: @tweet_loads)
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tweet")
    |> assign(
      :tweet,
      Tweets.get_tweet!(id, actor: socket.assigns.current_user, load: @tweet_loads)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tweet")
    |> assign(:tweet, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tweets")
    |> assign(:tweet, nil)
  end

  @impl true
  def handle_info({TwitterWeb.TweetLive.FormComponent, {:saved, tweet}}, socket) do
    tweet = Ash.load!(tweet, @tweet_loads, actor: socket.assigns.current_user)
    {:noreply, stream_insert(socket, :tweets, tweet)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    id
    |> Tweets.get_tweet!(actor: socket.assigns.current_user)
    |> Tweets.delete_tweet!(actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :tweets, %{id: id})}
  end

  @impl true
  def handle_event("like", %{"id" => id}, socket) do
    Tweets.like_tweet!(id, actor: socket.assigns.current_user)

    {:noreply, refetch_tweet(socket, id)}
  end

  @impl true
  def handle_event("dislike", %{"id" => id}, socket) do
    Tweets.dislike_tweet!(id, actor: socket.assigns.current_user)

    {:noreply, refetch_tweet(socket, id)}
  end

  @impl true
  def handle_event("unlike", %{"id" => id}, socket) do
    Tweets.unlike_tweet!(id, actor: socket.assigns.current_user)

    {:noreply, refetch_tweet(socket, id)}
  end

  defp refetch_tweet(socket, id) do
    stream_insert(
      socket,
      :tweets,
      Ash.get!(Twitter.Tweets.Tweet, id, actor: socket.assigns.current_user, load: @tweet_loads)
    )
  end
end
