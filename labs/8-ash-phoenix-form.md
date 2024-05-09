# Lab 8 - `AshPhoenix.Form`

## Relevant Documentation

- [AshPhoenix.Form](https://hexdocs.pm/ash_phoenix/2.0.0-rc.4/AshPhoenix.Form.html)

## Steps

1.  We can simplify a lot of our form code using `AshPhoenix.Form`. We get error handling, automatic setting of values, and more.

2.  To start, we will this `assign_form/1` helper to the bottom of `form_component.ex`.

```elixir
defp assign_form(%{assigns: %{tweet: tweet}} = socket) do
  form =
    if tweet do
      AshPhoenix.Form.for_update(tweet, :update,
        as: "tweet",
        actor: socket.assigns.current_user
      )
    else
      AshPhoenix.Form.for_create(Twitter.Tweets.Tweet, :create,
        as: "tweet",
        actor: socket.assigns.current_user
      )
    end

  assign(socket, form: to_form(form))
end
```

3. Then we can call it from our `update/2` handler. Replace your `update/2` function with the following code:

```elixir
@impl true
def update(assigns, socket) do
  {:ok,
   socket
   |> assign(assigns)
   |> assign_form()}
end
```

4. Now, update your `"save"` handler to use `AshPhoenix.Form.submit/2`

To do this, we'll change our `"save"` event handler to the following. Notice how this `AshPhoenix.Form.submit/2` works regardless of the action type.

```elixir
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
```

5. Then, we can modify our `<.simple_form >` to use this form.

```elixir
<.simple_form
  for={@form}
  id="tweet-form"
  phx-target={@myself}
  phx-submit="save"
>
  <.input label="Text" type="textarea" field={@form[:text]} />
  <:actions>
    <.button phx-disable-with="Saving...">Save Tweet</.button>
  </:actions>
</.simple_form>
```

6. We can now introduce a `"validate"` step, that will validate on keystroke. `AshPhoenix.Form` handles the complexity of that.

```elixir
@impl true
def handle_event("validate", %{"tweet" => tweet_params}, socket) do
  {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, tweet_params))}
end
```

7. Then we add this to our `<.simple_form` to add `phx-change="validate"`.

8. Now we can try it out our tweet form, and if you violate any validations on the tweet, you will see the validation errors automatically appear as soon as you meet the error conditions.
