defmodule Twitter.Accounts do
  @moduledoc false
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Twitter.Accounts.User do
      define :get_user_by_email, action: :read, get_by: :email
    end

    resource Twitter.Accounts.Token
  end
end
