create function list_articles_by_author_username(self bigint, _limit bigint, _offset bigint, _author_username text) returns setof article as
$$
declare
    _author_id bigint;
begin
    select id into _author_id from users where username = _author_username;

    if _author_id is null then
        return;
    end if;

    return query select slug::text,
                        title::text,
                        description::text,
                        body::text,
                        array_remove(array_agg(distinct (tag)), null)::text[]      as "tagList",
                        favorited(self, articles.id),
                        count(distinct (favorites.user_id))                        as "favoritesCount",
                        (username, bio, image, following(self, users.id))::profile as author,
                        "createdAt",
                        "updatedAt"
                 from articles
                          join users on articles.author_id = users.id
                          join profiles on users.id = profiles.user_id
                          left join tags on articles.id = tags.article_id
                          left join favorites on articles.id = favorites.article_id
                 where articles.author_id = _author_id
                 group by articles.id, slug, title, description, body, users.id, bio, image, "createdAt", "updatedAt"
                 limit coalesce(least(_limit, 100), 20) offset coalesce(greatest(_offset, 0), 0);
end;
$$ language plpgsql;
