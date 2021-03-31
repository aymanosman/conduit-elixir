create function list_articles_by_following(_self_id bigint,
                                           _limit bigint,
                                           _offset bigint) returns setof article as
$$
select slug,
       title,
       description,
       body,
       "tagList",
       favorited(_self_id, author_id),
       "favoritesCount",
       (author_username, author_bio, author_image, following(_self_id, author_id))::profile as author,
       "createdAt",
       "updatedAt"
from articles_view
where author_id in (select target from follows where source = _self_id)
limit coalesce(least(_limit, 100), 20) offset coalesce(greatest(_offset, 0), 0);
$$ language sql
