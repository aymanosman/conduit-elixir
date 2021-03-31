create function add_comment_to_article_by_slug(_user_id bigint, _slug text, _body text) returns comment as
$$
declare
    _article_id bigint;
    _comment_id bigint;
begin
    select id into _article_id from articles where slug = _slug;

    if _article_id is null then
        raise exception 'No valid article found';
    end if;

    insert into comments (body, article_id, author_id, "createdAt", "updatedAt")
    values (_body, _article_id, _user_id, now(), now())
    returning id into _comment_id;

    return get_comment_by_id(_comment_id, _user_id);
end;
$$ language plpgsql;
