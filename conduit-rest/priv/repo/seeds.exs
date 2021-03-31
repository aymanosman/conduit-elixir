# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Conduit.Repo.insert!(%Conduit.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, jake} =
  Conduit.Accounts.register_user(%{username: "jake", email: "jake@jake", password: "jakepass"})

{:ok, celeb} =
  Conduit.Accounts.register_user(%{
    username: "celeb_",
    email: "celeb_@celeb_",
    password: "celeb_pass"
  })

{:ok, _} =
  Conduit.Content.create_article(
    jake.token,
    %{
      title: "How to train dragons",
      description: "Ever wonder how?",
      body: "It takes a Jacobian",
      tagList: ["myth", "intro"]
    }
  )

{:ok, _} =
  Conduit.Content.create_article(
    jake.token,
    %{
      title: "How to train dragons 2",
      description: "It's not that hard",
      body: "You just have to practice",
      tagList: ["myth"]
    }
  )

{:ok, _} =
  Conduit.Content.create_article(
    celeb.token,
    %{title: "Trivial 1", description: "Not that interesting", body: "blah blah blah"}
  )
