create function unfavorite_article_by_slug(_user_id bigint, _slug text) returns article as
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

    delete from favorites where article_id = _article_id and user_id = _user_id;

    return get_article_by_id(_article_id, _user_id);
end;
$$ language plpgsql;
