create function update_article_by_slug(user_id bigint,
                                       _slug text,
                                       _title text,
                                       _description text,
                                       _body text,
                                       _tagList text[]) returns article as
$$
declare
    _article_id bigint;
    _tag        text;
begin
    select id
    into _article_id
    from articles
    where slug = _slug
      and author_id = user_id;

    if _article_id is null then
        raise exception 'No valid article found';
    end if;

    if _title is not null then
        _slug = slugify(_title); -- ! MUTATION
    end if;

    update articles
    set title       = coalesce(_title, title),
        slug        = coalesce(_slug, slug),
        description = coalesce(_description, description),
        body        = coalesce(_body, body)
    where id = _article_id;

    if _tagList is not null then
        delete
        from tags
        where article_id = _article_id;

        -- TODO extract function
        foreach _tag in array _tagList
            loop
                insert
                into tags (tag, article_id)
                values (_tag, _article_id);
            end loop;
    end if;
    return get_article_by_id(_article_id, user_id);
end;
$$
    language plpgsql;
