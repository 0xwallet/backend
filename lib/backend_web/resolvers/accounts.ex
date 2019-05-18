
defmodule BackendWeb.Resolvers.Accounts do


  def find_user(_parent, %{id: id}, _resolution) do
    case Backend.Accounts.find_user(id) do
      nil ->
        {:error, "User ID #{id} not found"}
      user ->
        {:ok, user}
    end
  end

  def create_user(_parent, args, %{context: %{current_user: %{admin: true}}}) do
    Backend.Accounts.create_user(args)
  end

  def create_user(_parent, _args, _resolution) do
    {:error, "Access denied"}
  end

  def send_code(_parent, %{email: email}, _resolution) do
    if email_valid?(email) do
      case Backend.Accounts.send_code(email) do
        {:ok, _} ->
          {:ok, "Sent authentication code."}
        :error ->
          {:error, "Please wait."}
      end
    else
      {:error, "Invalid email."}
    end
  end

  def authorization_token(_parent, %{email: email, code: code}, _resolution) do
    if email_valid?(email) do
      case Backend.Accounts.authorization_token(email, code) do
        {:ok, contact} ->
          {:ok, contact.token}
        :error ->
          {:error, "Incorrect email or code."}
      end
    else
      {:error, "Invalid email."}
    end
  end


  ## Helpers

  defp email_valid?(email) do
    Regex.match?(~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/, email)
  end
end
