defmodule Backend.Accounts do
  import Ecto.Query

  alias Backend.{Accounts, Repo}

  def find_user(id) do
    Repo.get(Accounts.User, id)
  end

  def create_user(attrs) do
    {contact_attrs, user_attrs} = Map.pop(attrs, :contact)

    Repo.transaction fn ->
      with {:ok, contact} <- create_contact(contact_attrs),
           {:ok, user} <- do_create_user(user_attrs, contact) do
        %{user | contacts: [contact]}
      end
    end
  end

  def authorization_token(email, code) do
    case find_contact(email) do
      nil ->
        :error
      %{code: ^code} = contact ->
        if expired?(code) do
          :error
        else
          token = gen_token()
          Accounts.Contact.changeset(contact, %{token: token})
          |> Repo.update()
        end
      _ ->
        :error
    end
  end

  def create_contact(attrs) do
    attrs
    |> Accounts.Contact.changeset()
    |> Repo.insert()
  end

  def find_contact(email) do
    from(c in Accounts.Contact,
      where: c.type == "email",
      where: c.value == ^email)
    |> Repo.one()
  end

  def do_create_user(attrs, contact) do
    attrs
    |> Map.put(:contact_id, contact.id)
    |> Accounts.User.changeset()
    |> Repo.insert()
  end

  def send_code(email) do
    find_contact(email)
    |> do_send_code(email)
  end

  def do_send_code(nil, email) do
    {time, code} = auth_code_with_time()
    send_auth_email(email, code)

    %{
      type: "email",
      value: email,
      code: time <> " " <> code
    }
    |> Accounts.Contact.changeset()
    |> Repo.insert()
  end

  def do_send_code(%Accounts.Contact{} = contact, email) do
    {time, _code} = parse_code(contact.code)

    if expired?(time) do
      {time, code} = auth_code_with_time()
      send_auth_email(email, code)

      Accounts.Contact.changeset(contact, %{code: time <> " " <> code})
      |> Repo.update()
    else
      :error
    end
  end



  ## Helpers

  @expire_second 300

  defp expired?(time) do
    :os.system_time(:second) - time > @expire_second
  end

  defp gen_token do
    :crypto.strong_rand_bytes(32) |> Base.encode16()
  end

  defp auth_code_with_time do
    code =
      :crypto.strong_rand_bytes(10)
      |> Base.encode32()
      |> String.slice(0, 6)
    time =
      :os.system_time(:second)
      |> to_string()
    {time, code}
  end

  defp parse_code(str) do
    [time, code] = String.split(str)
    {String.to_integer(time), code}
  end

  defp send_auth_email(email, code) do
    spawn(fn ->
      Backend.EmailService.auth_email(email, code)
    end)
  end

end
