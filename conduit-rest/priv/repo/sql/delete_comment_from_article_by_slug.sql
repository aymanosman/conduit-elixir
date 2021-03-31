create function delete_comment_from_article_by_slug(_user_id bigint, _slug text, _comment_id bigint) returns boolean as
$$
declare
    _article_id bigint;
    _deleted_id bigint;
begin
    select id into _article_id from articles where slug = _slug;

    if _article_id is null then
        raise exception 'No valid article found';
    end if;

    delete
    from comments
    where id = _comment_id
      and author_id = _user_id
      and article_id = _article_id
    returning id into _deleted_id;

    if _deleted_id is null then
        return false;
    else
        return true;
    end if;
end;
$$ language plpgsql;
