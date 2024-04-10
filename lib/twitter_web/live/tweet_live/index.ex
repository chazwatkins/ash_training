defmodule TwitterWeb.TweetLive.Index do
  use TwitterWeb, :live_view

  @tweet_loads [:user_email, :like_count, :liked_by_me, :text_length]

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
      <:col :let={{_id, tweet}} label="Author">
        <%= tweet.user_email %>
      </:col>

      <:col :let={{_id, tweet}} label="Text">
        <%= tweet.text %>
      </:col>

      <:col :let={{_id, tweet}} label="Length">
        <%= tweet.text_length %>/255
      </:col>

      <:col :let={{_id, tweet}} label="Likes">
        <%= if tweet.liked_by_me do %>
          <button phx-click="unlike" phx-value-id={tweet.id}>
            <.icon name="hero-heart-solid" class="text-red-600" /> <%= tweet.like_count %>
          </button>
        <% else %>
          <button phx-click="like" phx-value-id={tweet.id}>
            <.icon name="hero-heart" /> <%= tweet.like_count %>
          </button>
        <% end %>
      </:col>

      <:action :let={{_id, tweet}}>
        <div class="sr-only">
          <.link navigate={~p"/tweets/#{tweet}"}>Show</.link>
        </div>

        <%= if Ash.can?({tweet, :update}, @current_user) do %>
          <.link patch={~p"/tweets/#{tweet}/edit"}>Edit</.link>
        <% end %>
      </:action>

      <:action :let={{id, tweet}}>
        <%= if Ash.can?({tweet, :destroy}, @current_user) do %>
          <.link
            phx-click={JS.push("delete", value: %{id: tweet.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        <% end %>
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
     socket
     |> stream(
       :tweets,
       Twitter.Tweets.feed!(actor: socket.assigns[:current_user], load: @tweet_loads)
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tweet")
    |> assign(:tweet, Twitter.Tweets.get_tweet!(id, actor: socket.assigns.current_user))
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
    {:noreply, stream_insert(socket, :tweets, Ash.load!(tweet, @tweet_loads, actor: socket.assigns.current_user))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Twitter.Tweets.delete_tweet!(id, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :tweets, %{id: id})}
  end

  def handle_event("like", %{"id" => id}, socket) do
    Twitter.Tweets.like!(id, actor: socket.assigns.current_user)

    {:noreply, refetch_tweet(socket, id)}
  end

  def handle_event("unlike", %{"id" => id}, socket) do
    Twitter.Tweets.unlike!(id, actor: socket.assigns.current_user)

    {:noreply, refetch_tweet(socket, id)}
  end

  defp refetch_tweet(socket, id) do
    stream_insert(
      socket,
      :tweets,
      Twitter.Tweets.get_tweet!(id, actor: socket.assigns.current_user, load: @tweet_loads)
    )
  end
end
