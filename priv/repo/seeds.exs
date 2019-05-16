alias Backend.{Accounts, Content}

user =
  %Accounts.User{}
  |> Accounts.User.changeset(%{name: "Test", password: "test"})
  |> Backend.Repo.insert!()

user
|> Ecto.build_assoc(:contacts, %{type: "email", value: "test@test.com"})
|> Backend.Repo.insert!()

Content.create_post(user, %{title: "Test Post", body: "Lorem Ipsum", published_at: ~N[2019-05-15 10:00:00]})
