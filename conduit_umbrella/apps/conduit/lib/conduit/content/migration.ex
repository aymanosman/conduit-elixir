defmodule Conduit.Content.Migration do
  def schemas(conn) do
    execute(conn, "create schema content")
  end

  def types(conn) do
    execute(conn, """
        create type content.article as
        (
            slug            text,
            title           text,
            description     text,
            body            text,
            tag_list        text[],
            favorited       boolean,
            favorites_count bigint,
            author          social.profile,
            created_at      timestamp(0),
            updated_at      timestamp(0)
        )
    """)

    execute(conn, """
    create type content.comment as
    (
      id         bigint,
      body       text,
      created_at timestamp(0),
      updated_at timestamp(0),
      author     social.profile
    )
    """)
  end

  def tables(conn) do
    execute(conn, """
    create table content.articles
    (
        id          bigserial primary key,
        slug        text         not null,
        title       text         not null,
        description text         not null,
        body        text         not null,
        author_id   bigint references accounts.users (id),
        created_at  timestamp(0) not null default now(),
        updated_at  timestamp(0) not null default now()
    );
    """)

    execute(conn, """
    create unique index articles_slug_index
      on content.articles (slug);
    """)

    execute(conn, """
        create table content.tags
        (
            id         bigserial primary key,
            tag        text not null,
            article_id bigint references content.articles (id) on delete cascade
        );
    """)

    execute(conn, """
        create unique index tags_unique_index
        on content.tags (tag, article_id);

    """)

    execute(conn, """
        create index tags_tag_index
        on content.tags (tag);

    """)

    execute(conn, """
        create index tags_article_index
        on content.tags (article_id);
    """)

    execute(conn, """
    create table content.favorites
    (
    id         bigserial primary key,
    user_id    bigint references accounts.users (id),
    article_id bigint references content.articles (id)
    );
    """)

    execute(conn, """
        create unique index favorites_unique_index
    on content.favorites (user_id, article_id);
    """)

    execute(conn, """
    create index favorites_username_index
    on content.favorites (user_id);
    """)

    execute(conn, """
    create index favorites_slug_index
    on content.favorites (article_id);
    """)

    execute(conn, """
    create table content.comments
    (
      id         bigserial primary key,
      body       text,
      article_id bigint references content.articles (id) on delete cascade,
      author_id  bigint references accounts.users (id) on delete cascade,
      created_at timestamp(0) not null default now(),
      updated_at timestamp(0) not null default now()
    )
    """)
  end

  def views(conn) do
    execute(conn, """
        create view content.articles_view as
        select articles.id,
               articles.slug,
               articles.title,
               articles.description,
               articles.body,
               array_remove(array_agg(distinct (tags.tag)), null) as tag_list,
               count(distinct (favorites.*))                      as favorites_count,
               articles.created_at,
               articles.updated_at,
               profiles_view.id                                   as author_id,
               profiles_view.username                             as author_username,
               profiles_view.bio                                  as author_bio,
               profiles_view.image                                as author_image
        from content.articles
                 join social.profiles_view on articles.author_id = profiles_view.id
                 left join content.tags on articles.id = tags.article_id
                 left join content.favorites on articles.id = favorites.article_id
        group by articles.id,
                 articles.slug,
                 articles.title,
                 articles.description,
                 articles.body,
                 articles.created_at,
                 articles.updated_at,
                 profiles_view.id,
                 profiles_view.username,
                 profiles_view.bio,
                 profiles_view.image;
    """)

    execute(conn, """
    create view content.comments_view as
    select comments.id,
       comments.body,
       comments.created_at,
       comments.updated_at,
       comments.article_id,
       profiles_view.id       as author_id,
       profiles_view.username as author_username,
       profiles_view.bio      as author_bio,
       profiles_view.image    as author_image
    from content.comments
         join social.profiles_view on author_id = profiles_view.id
    """)
  end

  def functions(conn) do
    execute(conn, """
        create function content.favorited(_self_id bigint,
                                          _article_id bigint) returns boolean as
        $$
        begin
            if _self_id is not null then
                return exists(select 1
                              from content.favorites
                              where user_id = _self_id
                                and article_id = _article_id);
            else
                return null;
            end if;
        end;
        $$ language plpgsql;
    """)

    execute(conn, """
    create function content.get_article_by_id(_id bigint,
                                              _self_id bigint) returns setof content.article as
    $$
    select slug,
       title,
       description,
       body,
       tag_list,
       content.favorited(_self_id, id),
       favorites_count,
       (author_username,
        author_bio,
        author_image,
        social.following(_self_id, author_id))::social.profile as author,
       created_at,
       updated_at
    from content.articles_view
    where id = _id;
    $$ language sql
    """)

    execute(conn, """
        create function content.create_article(_self_id bigint,
                                               _title text,
                                               _description text,
                                               _body text,
                                               _tag_list text[]) returns setof content.article as
        $$
        declare
            _article_id bigint;
        begin
            _article_id := nextval('content.articles_id_seq');

            insert into events.events (event_type, data)
            values ('article_created', json_build_object('id', _article_id,
                                                         'title', _title,
                                                         'description', _description,
                                                         'body', _body,
                                                         'author_id', _self_id,
                                                         'tag_list', _tag_list));

            return next content.get_article_by_id(_article_id, _self_id);
        end;
        $$ language plpgsql
    """)

    execute(conn, """
        create function content.slugify(text) returns text as
        $$
        begin
            return regexp_replace(lower(trim(both from $1)), '\s+', '-', 'g');
        end;
        $$ language plpgsql;
    """)

    execute(conn, """
        create function content.article_created() returns trigger
            language plpgsql as
        $$
        declare
            _article_id bigint;
            _slug       text;
            _tag        text;
            _created_at timestamp(0);
            _updated_at timestamp(0);
        begin
            _article_id := (new.data -> 'id')::bigint;
            _slug := content.slugify((new.data ->> 'title'));
            _created_at := now();
            _updated_at := now();

            insert
            into content.articles (id, slug, title, description, body, author_id, created_at, updated_at)
            values (_article_id,
                    _slug,
                    (new.data ->> 'title'),
                    (new.data ->> 'description'),
                    (new.data ->> 'body'),
                    (new.data -> 'author_id')::bigint,
                    _created_at,
                    _updated_at);

            if jsonb_typeof(new.data -> 'tag_list') != 'null' then
                for _tag in (select * from jsonb_array_elements_text(new.data -> 'tag_list'))
                    loop
                        insert
                        into content.tags (tag, article_id)
                        values (_tag, _article_id);
                    end loop;
            end if;

            new.data := jsonb_set(new.data, '{slug}', to_jsonb(_slug)) ||
                        jsonb_build_object('created_at', _created_at, 'updated_at', _updated_at);

            return new;
        end;
        $$
    """)

    execute(conn, """
    create function content.get_comment_by_id(_comment_id bigint,
                                              _user_id bigint) returns setof content.comment as
    $$
    select id,
       body,
       created_at,
       updated_at,
       (author_username,
        author_bio,
        author_image,
        social.following(_user_id, author_id))::social.profile as author
    from content.comments_view
    where id = _comment_id;
    $$ language sql
    """)

    execute(conn, """
    create function content.add_comment(_user_id bigint,
                                        _slug text,
                                        _body text) returns setof content.comment as
    $$
    declare
    _article_id bigint;
    _comment_id bigint;
    begin
    select id into _article_id from content.articles where slug = _slug;

    if _article_id is null then
        raise no_data_found using message = 'No valid article found';
    end if;

    _comment_id := nextval('content.comments_id_seq');

    insert into events.events (event_type, data)
    values ('comment_added', json_build_object('id', _comment_id,
                                               'body', _body,
                                               'author_id', _user_id,
                                               'article_id', _article_id));

    return next content.get_comment_by_id(_comment_id, _user_id);
    end;
    $$ language plpgsql
    """)

    execute(conn, """
    create function content.comment_added() returns trigger
    language plpgsql as
    $$
    declare
    _created_at timestamp(0);
    _updated_at timestamp(0);
    begin
    _created_at := now();
    _updated_at := now();

    insert into content.comments (id,
                          body,
                          article_id,
                          author_id,
                          created_at,
                          updated_at)
    values ((new.data -> 'id')::bigint,
            (new.data ->> 'body'),
            (new.data -> 'article_id')::bigint,
            (new.data -> 'author_id')::bigint,
            _created_at,
            _updated_at);

    new.data := new.data || jsonb_build_object('created_at', _created_at, 'updated_at', _updated_at);

    return new;
    end;
    $$
    """)

    execute(conn, """
    create function content.list_articles(self bigint,
                                          _limit bigint,
                                          _offset bigint) returns setof content.article as
    $$
    select slug,
       title,
       description,
       body,
       tag_list,
       content.favorited(self, id),
       favorites_count,
       (author_username,
        author_bio,
        author_image,
        social.following(self, author_id))::social.profile as author,
       created_at,
       updated_at
    from content.articles_view
    limit coalesce(least(_limit, 100), 20) offset coalesce(greatest(_offset, 0), 0);
    $$
    language sql;
    """)
  end

  def triggers(conn) do
    execute(conn, """
    create trigger article_created_trigger
    before insert
    on events.events
    for each row
    when (new.event_type = 'article_created')
    execute function content.article_created()
    """)

    execute(conn, """
    create trigger comment_added_trigger
    before insert
    on events.events
    for each row
    when (new.event_type = 'comment_added')
    execute function content.comment_added()
    """)
  end

  defp execute(conn, cmd) do
    Postgrex.query!(conn, cmd, [])
  end
end
