create function create_article(self bigint, _title text, _description text, _body text,
                               _tagList text array) returns article as
'
    declare
        _article_id bigint;
        _tag        text;
    begin
        insert into articles (slug, title, description, body, author_id, "createdAt", "updatedAt")
        values (slugify(_title), _title, _description, _body, self, now(), now())
        returning articles.id into _article_id;
        if _tagList is not null then
            foreach _tag in array _tagList
                loop
                    insert into tags (tag, article_id)
                    values (_tag, _article_id);
                end loop;
        end if;
        return get_article_by_id(_article_id, self);
    end;
' language plpgsql
