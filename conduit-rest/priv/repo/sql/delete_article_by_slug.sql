create function delete_article_by_slug(user_id bigint, _slug text) returns boolean as
$$
declare
    _article_id bigint;
begin
    select id
    into _article_id
    from articles
    where slug = _slug
      and author_id = user_id;

    if _article_id is null then
        return false;
    end if;

    delete
    from articles
    where id = _article_id;

    return true;
end;
$$
    language plpgsql;
