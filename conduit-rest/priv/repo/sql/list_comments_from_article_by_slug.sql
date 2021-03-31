create function list_comments_from_article_by_slug(_user_id bigint, _slug text) returns setof comment as
$$
declare
    _article_id bigint;
begin
    select id into _article_id from articles where slug = _slug;

    if _article_id is null then
        raise exception no_data_found;
    end if;

    return query select comments.id,
                        comments.body,
                        comments."createdAt",
                        comments."updatedAt",
                        (username, bio, image, following(_user_id, users.id))::profile as author
                 from comments
                          join users on comments.author_id = users.id
                          join profiles on users.id = profiles.user_id
                          join articles on comments.article_id = articles.id
                 where article_id = _article_id
                 order by comments."createdAt", comments.id;
end;
$$ language plpgsql;
