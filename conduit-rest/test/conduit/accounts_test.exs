defmodule Conduit.AccountsTest do
  use Conduit.DataCase, async: true

  alias Conduit.Accounts

  describe "users" do
    test "register_user/1 with valid data creates a user" do
      assert {:ok, user} =
               Accounts.register_user(%{
                 username: "jake",
                 email: "jake@jake",
                 password: "pass",
                 bio: "I work at statefarm",
                 image: nil
               })

      assert user.username == "jake"
      assert user.email == "jake@jake"
      assert user.bio == "I work at statefarm"
      assert user.image == nil
    end

    test "register_user/1 with duplicate username data returns an error" do
      assert {:ok, _} =
               Accounts.register_user(%{
                 username: "jake",
                 email: "jake@jake",
                 password: "pass",
                 bio: "I work at statefarm",
                 image: nil
               })

      assert {:error, error} =
               Accounts.register_user(%{
                 username: "jake",
                 email: "notjake@fake",
                 password: "pass",
                 bio: "I work at fakefarm",
                 image: nil
               })

      assert error.postgres.code == :unique_violation
      assert error.postgres.message =~ "duplicate key value violates unique constraint"
    end

    test "authenticate_user/2 with valid credentials returns user" do
      email = "bob@bob"
      password = "bobpass"

      assert {:ok, _} =
               Accounts.register_user(%{username: "bob", email: email, password: password})

      assert {:ok, user} = Accounts.authenticate_user(%{email: email, password: password})

      assert user.username == "bob"
      assert user.email == email
      assert user.bio == nil
      assert user.image == nil
    end

    test "authenticate_user/2 with invalid credentials returns error" do
      email = "bob@bob"
      password = "bobpass"

      assert {:ok, _} =
               Accounts.register_user(%{username: "bob", email: email, password: password})

      assert {:error, :not_found} =
               Accounts.authenticate_user(%{email: email, password: "wrongpass"})
    end

    def user_fixture() do
      Accounts.register_user(%{
        username: "jake",
        email: "jake@jake",
        password: "pass",
        bio: "I work at statefarm",
        image: nil
      })
    end

    test "get_current_user/1 with a valid token returns user" do
      assert {:ok, user} = user_fixture()
      assert {:ok, user2} = Accounts.get_current_user(user.token)

      assert user2.username == user.username
    end

    test "get_current_user/1 with an invalid token returns error" do
      assert {:ok, _user} = user_fixture()
      assert {:error, :unauthorized} = Accounts.get_current_user("garbage token")
    end

    # TODO test expired token and other claim validation

    test "update_user/2 can update a single attribute" do
      assert {:ok, user} = user_fixture()
      email = "jake@new"
      assert {:ok, user2} = Accounts.update_user(user.token, %{email: email})

      assert user.email != email
      assert user2.email == email
      assert user2.bio == user.bio
    end

    test "update_user/2 can update multiple attributes" do
      assert {:ok, user} = user_fixture()
      email = "jake@new"
      bio = "really interesting"
      image = "nice picture"

      assert {:ok, user2} =
               Accounts.update_user(user.token, %{email: email, bio: bio, image: image})

      assert user.email != email
      assert user.bio != bio
      assert user.image != image
      assert user2.email == email
      assert user2.bio == user2.bio
      assert user2.image == user2.image
    end
  end
end
