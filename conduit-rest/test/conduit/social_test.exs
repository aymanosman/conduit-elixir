defmodule Conduit.SocialTest do
  use Conduit.DataCase, async: true

  alias Conduit.{Accounts, Social}

  describe "profiles" do
    def user_fixture(attrs \\ %{}) do
      Accounts.register_user(
        %{
          username: "jake",
          email: "jake@jake",
          password: "pass",
          bio: "I work at statefarm",
          image: nil
        }
        |> Map.merge(attrs)
      )
    end

    test "get_profile/2 unauthenticated will return profile and omit 'following'" do
      username = "celeb_"
      email = "a@b"
      bio = "making money"

      assert {:ok, _user} =
               Accounts.register_user(%{
                 username: username,
                 email: email,
                 password: "pass",
                 bio: bio
               })

      assert {:ok, user2} = Social.get_profile_by_username(nil, username)

      assert user2.username == username
      assert user2.bio == bio
    end

    test "get_profile/2 authenticated will return profile and include 'following'" do
      {:ok, jake} = user_fixture()

      username = "celeb_"
      email = "a@b"
      bio = "making money"

      assert {:ok, _user} =
               Accounts.register_user(%{
                 username: username,
                 email: email,
                 password: "pass",
                 bio: bio
               })

      assert {:ok, user2} = Social.get_profile_by_username(jake.token, username)

      assert user2.username == username
      assert user2.bio == bio
      assert user2.following == false
    end

    test "follow/2 authenticated user can follow another user" do
      {:ok, jake} = user_fixture()
      {:ok, celeb} = user_fixture(%{username: "celeb", email: "celeb@celeb"})

      assert {:ok, celeb_profile} = Social.follow(jake.token, celeb.username)

      assert celeb_profile.following == true

      {:ok, celeb_profile2} = Social.get_profile_by_username(jake.token, celeb.username)

      assert celeb_profile2.following == true
    end

    test "follow/2 following twice does not lead to an error" do
      {:ok, jake} = user_fixture()
      {:ok, celeb} = user_fixture(%{username: "celeb", email: "celeb@celeb"})

      assert {:ok, _} = Social.follow(jake.token, celeb.username)
      assert {:ok, _} = Social.follow(jake.token, celeb.username)
    end

    test "unfollow/2 authenticated user can unfollow another user" do
      {:ok, jake} = user_fixture()
      {:ok, celeb} = user_fixture(%{username: "celeb", email: "celeb@celeb"})

      # follow
      assert {:ok, celeb_profile} = Social.follow(jake.token, celeb.username)
      assert celeb_profile.following == true
      {:ok, celeb_profile2} = Social.get_profile_by_username(jake.token, celeb.username)
      assert celeb_profile2.following == true

      # unfollow
      assert {:ok, celeb_profile} = Social.unfollow(jake.token, celeb.username)
      assert celeb_profile.following == false
      {:ok, celeb_profile2} = Social.get_profile_by_username(jake.token, celeb.username)
      assert celeb_profile2.following == false
    end
  end
end
