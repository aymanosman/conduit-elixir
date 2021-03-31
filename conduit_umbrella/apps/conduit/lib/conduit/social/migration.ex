defmodule Conduit.Social.Migration do
  def schemas(conn) do
    execute(conn, "create schema social")
  end

  def types(conn) do
    execute(conn, """
    create type social.profile as
    (
        username  text,
        bio       text,
        image     text,
        following boolean
    )
    """)
  end

  def tables(conn) do
    execute(conn, """
    create table social.profiles (
      user_id bigint references accounts.users (id),
      bio text,
      image text
    )
    """)
  end

  def views(conn) do
    execute(conn, """
    create view social.profiles_view as
    select users.id,
           users.username,
           profiles.bio,
           profiles.image
    from social.profiles
             join accounts.users on profiles.user_id = users.id;
    """)
  end

  def functions(conn) do
    execute(conn, """
        create function social.following(self bigint, other bigint) returns boolean as
        $$
        begin
            case
                when self is null then return null;
                when self = other then return null;
                else return exists(select 1 from follows where source = self and target = other);
                end case;
        end;
        $$ language plpgsql;
    """)
  end

  def triggers(_conn) do
  end

  defp execute(conn, cmd) do
    Postgrex.query!(conn, cmd, [])
  end
end
