defmodule Conduit.ContentTest do
  use Conduit.DataCase, async: true

  alias Conduit.{Accounts, Content, Social}

  def user_fixture(attrs \\ %{}) do
    username = attrs[:username] || "bob"

    Accounts.register_user(%{
      username: username,
      email: attrs[:email] || "#{username}@#{username}",
      password: attrs[:password] || "#{username}_pass",
      bio: attrs[:bio],
      image: attrs[:image]
    })
  end

  def article_fixture(token, attrs \\ %{}) do
    title = "Some Thing"

    Content.create_article(
      token,
      %{
        title: attrs[:title] || title,
        description: attrs[:description] || title <> " description",
        body: attrs[:body] || title <> " body",
        tagList: attrs[:tagList]
      }
    )
  end

  test "create_article/2 with valid data creates an article" do
    {:ok, jack} = user_fixture(%{username: "jack"})

    assert {:ok, article} =
             Content.create_article(
               jack.token,
               %{
                 title: "How to Train Dragons 1",
                 description: "This is a description",
                 body: "This is some body",
                 tagList: ["myth", "dragons"]
               }
             )

    assert article.slug == "how-to-train-dragons-1"
  end

  test "create_article/2 with missing description returns a changeset error" do
    {:ok, jack} = user_fixture(%{username: "jack"})

    assert {:error, %Ecto.Changeset{}} =
             Content.create_article(
               jack.token,
               %{
                 title: "How to Train Dragons 1",
                 # missing description
                 body: "This is some body",
                 tagList: ["myth", "dragons"]
               }
             )
  end

  test "create_article/2 with duplicate title returns a postgres error" do
    {:ok, jack} = user_fixture(%{username: "jack"})

    assert {:ok, _article} =
             Content.create_article(
               jack.token,
               %{
                 title: "How to Train Dragons 1",
                 description: "This is a description",
                 body: "This is some body",
                 tagList: ["myth", "dragons"]
               }
             )

    assert {
             :error,
             %Postgrex.Error{
               postgres: %{
                 code: :unique_violation
               }
             }
           } =
             Content.create_article(
               jack.token,
               %{
                 title: "How to Train Dragons 1",
                 description: "This is a description",
                 body: "This is some body",
                 tagList: ["myth", "dragons"]
               }
             )
  end

  test "get_article/1 unauthenticated will returns article and omit 'favorited'" do
    {:ok, jack} = user_fixture(%{username: "jack"})

    assert {:ok, article} = article_fixture(jack.token)

    assert {:ok, article2} = Content.get_article_by_slug(nil, article.slug)

    assert article2.title == article.title
    assert article2.description == article.description
    assert article2[:favorited] == nil
    assert article2.favoritesCount == 0
  end

  test "get_article/2 authenticated will returns article and include 'favorited'" do
    {:ok, jack} = user_fixture(%{username: "jack"})

    assert {:ok, article} = article_fixture(jack.token)

    assert {:ok, article2} = Content.get_article_by_slug(jack.token, article.slug)

    assert article2.title == article.title
    assert article2.description == article.description
    assert article2.favorited == false
    assert article2.favoritesCount == 0
  end

  test "update_article/3 can update the title and the slug is automatically updated" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, init_article} = article_fixture(jack.token)

    new_title = "New Title"

    assert {:ok, article} =
             Content.update_article_by_slug(jack.token, init_article.slug, %{title: new_title})

    assert article.description == init_article.description
    assert article.title == new_title
    assert article.slug == "new-title"
  end

  test "update_article/3 can update multiple attributes" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, init_article} = article_fixture(jack.token)

    new_title = "New Title"
    new_body = "New Body"

    assert {:ok, article} =
             Content.update_article_by_slug(
               jack.token,
               init_article.slug,
               %{
                 title: new_title,
                 body: new_body
               }
             )

    assert article.description == init_article.description
    assert article.title == new_title
    assert article.body == new_body
  end

  test "delete_article_by_slug/2 succeeds if performed by author of article" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, article} = article_fixture(jack.token)

    assert :ok = Content.delete_article_by_slug(jack.token, article.slug)

    assert {:error, :not_found} = Content.get_article_by_slug(nil, article.slug)
  end

  test "delete_article_by_slug/2 fails if not performed by author of article" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, jill} = user_fixture(%{username: "jill"})
    {:ok, article} = article_fixture(jack.token)

    assert {:error, :not_found} = Content.delete_article_by_slug(jill.token, article.slug)

    assert {:ok, _} = Content.get_article_by_slug(nil, article.slug)
  end

  test "list_articles/0" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, jill} = user_fixture(%{username: "jill"})

    {:ok, article1} = article_fixture(jack.token, %{title: "one"})
    {:ok, _} = article_fixture(jack.token, %{title: "two"})
    {:ok, _} = article_fixture(jack.token, %{title: "three"})
    {:ok, _} = article_fixture(jill.token, %{title: "four"})
    {:ok, article5} = article_fixture(jill.token, %{title: "five"})

    {:ok, articles, articles_count} = Content.list_articles()

    assert Enum.count(articles) == 5
    assert articles_count == 5
    assert Enum.at(articles, 0).slug == article1.slug
    assert Enum.at(articles, 4).slug == article5.slug
  end

  test "list_articles/2 by tag" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, jill} = user_fixture(%{username: "jill"})

    {:ok, _} = article_fixture(jack.token, %{title: "one", tagList: ["a", "b", "c"]})
    {:ok, _} = article_fixture(jack.token, %{title: "two", tagList: ["a", "b"]})
    {:ok, _} = article_fixture(jack.token, %{title: "three", tagList: ["a", "b"]})
    {:ok, _} = article_fixture(jill.token, %{title: "four", tagList: ["a"]})
    {:ok, _} = article_fixture(jill.token, %{title: "five", tagList: ["a"]})

    {:ok, articles_a, _} = Content.list_articles(nil, %{tag: "a"})
    {:ok, articles_b, _} = Content.list_articles(nil, %{tag: "b"})
    {:ok, articles_c, _} = Content.list_articles(nil, %{tag: "c"})

    assert Enum.count(articles_a) == 5
    assert Enum.count(articles_b) == 3
    assert Enum.count(articles_c) == 1
  end

  test "list_articles/2 by author" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, jill} = user_fixture(%{username: "jill"})

    {:ok, _} = article_fixture(jack.token, %{title: "one"})
    {:ok, _} = article_fixture(jack.token, %{title: "two"})
    {:ok, _} = article_fixture(jack.token, %{title: "three"})
    {:ok, _} = article_fixture(jill.token, %{title: "four"})
    {:ok, _} = article_fixture(jill.token, %{title: "five"})

    {:ok, articles_jack, _} = Content.list_articles(nil, %{author: "jack"})
    {:ok, articles_jill, _} = Content.list_articles(nil, %{author: "jill"})

    assert Enum.count(articles_jack) == 3
    assert Enum.count(articles_jill) == 2
  end

  test "list_articles/2 by favorited" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, jill} = user_fixture(%{username: "jill"})

    {:ok, _} = article_fixture(jack.token, %{title: "one"})
    {:ok, _} = article_fixture(jack.token, %{title: "two"})
    {:ok, _} = article_fixture(jack.token, %{title: "three"})
    {:ok, _} = article_fixture(jill.token, %{title: "four"})
    {:ok, _} = article_fixture(jill.token, %{title: "five"})

    assert {:ok, one} = Content.favorite_article_by_slug(jill.token, "one")
    assert {:ok, two} = Content.favorite_article_by_slug(jill.token, "two")
    assert {:ok, four} = Content.favorite_article_by_slug(jill.token, "four")

    {:ok, articles_jack, _} = Content.list_articles(nil, %{favorited: "jack"})
    {:ok, articles_jill, _} = Content.list_articles(nil, %{favorited: "jill"})

    assert Enum.count(articles_jack) == 0
    assert Enum.count(articles_jill) == 3
    assert Enum.map(articles_jill, & &1.slug) == [one.slug, two.slug, four.slug]
  end

  test "list_articles/2 by favorited returns [] if user doesn't exist" do
    {:ok, articles_jack, _} = Content.list_articles(nil, %{favorited: "jack"})
    assert Enum.count(articles_jack) == 0
  end

  test "favorite_article_by_slug/2" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, jill} = user_fixture(%{username: "jill"})

    {:ok, _} = article_fixture(jack.token, %{title: "one"})
    {:ok, _} = article_fixture(jack.token, %{title: "two"})
    {:ok, _} = article_fixture(jack.token, %{title: "three"})
    {:ok, _} = article_fixture(jill.token, %{title: "four"})
    {:ok, _} = article_fixture(jill.token, %{title: "five"})

    assert {:ok, two} = Content.favorite_article_by_slug(jill.token, "two")
    assert {:ok, three} = Content.favorite_article_by_slug(jill.token, "three")

    assert two.favorited == true
    assert three.favorited == true
  end

  test "unfavorite_article_by_slug/2" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, jill} = user_fixture(%{username: "jill"})

    {:ok, _} = article_fixture(jack.token, %{title: "one"})

    assert {:ok, %{favorited: false}} = Content.get_article_by_slug(jill.token, "one")
    assert {:ok, %{favorited: true}} = Content.favorite_article_by_slug(jill.token, "one")
    assert {:ok, %{favorited: false}} = Content.unfavorite_article_by_slug(jill.token, "one")
  end

  test "add_comment/3" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, _} = article_fixture(jack.token, %{title: "one"})

    body = "Nice article!"
    assert {:ok, comment} = Content.add_comment(jack.token, "one", %{body: body})

    assert comment.body == body
    assert comment.author.username == "jack"
  end

  test "delete_comment/3 succeeds if performed by the author of the comment" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, _} = article_fixture(jack.token, %{title: "one"})

    assert {:ok, comment} = Content.add_comment(jack.token, "one", %{body: "body of comment"})
    assert :ok = Content.delete_comment(jack.token, "one", comment.id)
  end

  test "delete_comment/3 fails if not performed by the author of the comment" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, jill} = user_fixture(%{username: "jill"})
    {:ok, _} = article_fixture(jack.token, %{title: "one"})

    assert {:ok, comment} = Content.add_comment(jack.token, "one", %{body: "body of comment"})
    assert {:error, :not_found} = Content.delete_comment(jill.token, "one", comment.id)
  end

  test "list_tags/0" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, _} = article_fixture(jack.token, %{title: "one", tagList: ["t1", "t3"]})
    {:ok, _} = article_fixture(jack.token, %{title: "two", tagList: ["t2", "t3"]})
    {:ok, _} = article_fixture(jack.token, %{title: "three", tagList: ["t3", "t4"]})

    assert {:ok, tags} = Content.list_tags()

    assert Enum.sort(tags) == ["t1", "t2", "t3", "t4"]
  end

  test "feed_articles/2" do
    {:ok, jack} = user_fixture(%{username: "jack"})
    {:ok, jill} = user_fixture(%{username: "jill"})

    {:ok, _} = Social.follow(jill.token, "jack")

    {:ok, _} = article_fixture(jack.token, %{title: "one"})
    {:ok, _} = article_fixture(jack.token, %{title: "two"})
    {:ok, _} = article_fixture(jack.token, %{title: "three"})
    {:ok, _} = article_fixture(jill.token, %{title: "four"})
    {:ok, _} = article_fixture(jill.token, %{title: "five"})

    {:ok, articles, articles_count} = Content.feed_articles(jill.token)

    assert Enum.count(articles) == 3
    assert articles_count == 3
  end
end
