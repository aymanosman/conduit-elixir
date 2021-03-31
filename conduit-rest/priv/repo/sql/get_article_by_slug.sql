create function get_article_by_slug(_slug text, self bigint) returns setof article as
'
    select slug,
           title,
           description,
           body,
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
    where articles.slug = _slug
    group by articles.id, slug, title, description, body, users.id, bio, image, "createdAt", "updatedAt";
' language sql
