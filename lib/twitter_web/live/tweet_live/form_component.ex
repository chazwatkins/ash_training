defmodule TwitterWeb.TweetLive.FormComponent do
  @moduledoc false
  use TwitterWeb, :live_component

  alias Twitter.Tweets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage tweet records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="tweet-form"
        phx-target={@myself}
        phx-submit="save"
        phx-change="validate"
      >
        <.input label="Text" type="textarea" name="tweet[text]" value={@tweet && @tweet.text} />
        <.input label="Label" type="text" name="tweet[label]" value={@tweet && @tweet.label} />
        <.input
          label="Private?"
          type="checkbox"
          name="tweet[private]"
          value={@tweet && @tweet.private}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Tweet</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"tweet" => tweet_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, tweet_params))}
  end

  @impl true
  def handle_event("save", %{"tweet" => tweet_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: tweet_params) do
      {:ok, tweet} ->
        notify_parent({:saved, tweet})

        socket =
          socket
          |> put_flash(:info, "Tweet #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{tweet: tweet}} = socket) do
    form =
      if tweet do
        Tweets.form_to_update_tweet(tweet,
          as: "tweet",
          actor: socket.assigns.current_user
        )
      else
        Tweets.form_to_create_tweet(
          as: "tweet",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
