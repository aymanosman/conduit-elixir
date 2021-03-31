create view articles_view as
select articles.id,
       articles.slug,
       articles.title,
       articles.description,
       articles.body,
       array_remove(array_agg(distinct (tags.tag)), null)::text[] as "tagList",
       count(distinct (favorites.user_id))                        as "favoritesCount",
       articles."createdAt",
       articles."updatedAt",
       profiles_view.id                                           as author_id,
       profiles_view.username                                     as author_username,
       profiles_view.bio                                          as author_bio,
       profiles_view.image                                        as author_image
from articles
         join profiles_view on author_id = profiles_view.id
         left join tags on articles.id = tags.article_id
         left join favorites on articles.id = favorites.article_id
group by articles.id,
         articles.slug,
         articles.title,
         articles.description,
         articles.body,
         articles."createdAt",
         articles."updatedAt",
         profiles_view.id,
         profiles_view.username,
         profiles_view.bio,
         profiles_view.image;
