create function favorite_article_by_slug(user_id bigint, _slug text) returns article as
$$
declare
    _article_id bigint;
begin
    select id
    into _article_id
    from articles
    where slug = _slug;

    if _article_id is null then
        raise exception 'No valid article found';
    end if;

    insert into favorites (user_id, article_id)
    values (user_id, _article_id);

    return get_article_by_id(_article_id, user_id);

exception
    when unique_violation then
        return get_article_by_id(_article_id, user_id);
end;
$$ language plpgsql
