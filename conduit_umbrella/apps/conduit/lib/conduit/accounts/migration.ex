defmodule Conduit.Accounts.Migration do
  def schemas(conn) do
    execute(conn, "create schema citext")
    execute(conn, "create extension citext schema citext")
    execute(conn, "create schema accounts")
  end

  def types(conn) do
    execute(conn, """
    create type accounts.user as
    (
      id       bigint,
      username text,
      email    citext.citext,
      password text,
      bio      text,
      image    text
    );
    """)
  end

  def tables(conn) do
    execute(conn, """
    create table accounts.users (
      id       bigserial primary key,
      username text not null,
      email    citext.citext not null,
      password text not null
    )
    """)
  end

  def indexes(conn) do
    execute(conn, """
    create unique index users_username_index
    on accounts.users (username);
    """)

    execute(conn, """
    create unique index users_email_index
    on accounts.users (email);
    """)
  end

  def views(conn) do
    execute(conn, """
    create view accounts.users_view as
    select users.id,
           users.username,
           users.email,
           users.password,
           profiles.bio,
           profiles.image
    from accounts.users join social.profiles on users.id = profiles.user_id
    """)
  end

  def functions(conn) do
    execute(conn, """
    create function accounts.get_user_by_id(_id bigint) returns setof accounts.user
    language sql as
    $$
    select *
    from accounts.users_view
    where id = _id;
    $$
    """)

    execute(conn, """
    create function accounts.register_user(_username text,
                                           _email text,
                                           _password text,
                                           _bio text,
                                           _image text) returns setof accounts.user
    language plpgsql as
    $$
    declare _id bigint;
    begin
      _id := nextval('accounts.users_id_seq');

      insert into events.events (event_type, data)
      values ('user_registered', json_build_object('id', _id,
                                                   'username', _username,
                                                   'email', _email,
                                                   'password', _password,
                                                   'bio', _bio,
                                                   'image', _image));

      return next accounts.get_user_by_id(_id);
    end;
    $$
    """)

    execute(conn, """
    create function accounts.user_registered() returns trigger language plpgsql as
    $$
    begin
      insert into accounts.users (id, username, email, password)
      values ((new.data -> 'id')::bigint,
              (new.data ->> 'username'),
              (new.data ->> 'email'),
              (new.data ->> 'password'));

      insert into social.profiles (user_id, bio, image)
      values ((new.data -> 'id')::bigint,
              (new.data ->> 'bio'),
              (new.data ->> 'image'));

      return new;
    end;
    $$
    """)

    execute(conn, """
    create function accounts.authenticate_user(_email text,
                                               _password text) returns setof accounts.user as
    $$
    select *
    from accounts.users_view
    where email = _email
    and password = _password;
    $$ language sql;
    """)

    execute(conn, """
    create function accounts.update_user(_id bigint,
                                         _email text,
                                         _bio text,
                                         _image text,
                                         _username text,
                                         _password text) returns setof accounts.user as
    $$
    begin
    insert into events.events (event_type, data)
    values ('user_updated', json_build_object('id', _id,
                                              'email', _email,
                                              'bio', _bio,
                                              'image', _image,
                                              'username', _username,
                                              'password', _password));


    return next accounts.get_user_by_id(_id);
    end;
    $$ language plpgsql
    """)

    execute(conn, """
    create function accounts.user_updated() returns trigger
    language plpgsql as
    $$
    begin
    -- users
    update accounts.users
    set email    = coalesce((new.data ->> 'email'), email),
        username = coalesce((new.data ->> 'username'), username),
        password = coalesce((new.data ->> 'password'), password)
    where id = (new.data -> 'id')::bigint;

    -- profiles
    update social.profiles
    set bio   = coalesce((new.data ->> 'bio'), bio),
        image = coalesce((new.data ->> 'image'), image)
    where user_id = (new.data -> 'id')::bigint;

    return new;
    end;
    $$;
    """)
  end

  def triggers(conn) do
    execute(conn, """
    create trigger user_registered_trigger
      before insert
      on events.events
      for each row
      when (new.event_type = 'user_registered')
      execute function accounts.user_registered();
    """)

    execute(conn, """
    create trigger user_updated_trigger
    before insert
    on events.events
    for each row
    when ( new.event_type = 'user_updated' )
    execute function accounts.user_updated();
    """)
  end

  defp execute(conn, cmd) do
    Postgrex.query!(conn, cmd, [])
  end
end
