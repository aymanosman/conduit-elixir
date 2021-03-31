create function favorited(self bigint, _article_id bigint) returns boolean as
$$
begin
    if self is not null then
        return exists(select 1 from favorites where user_id = self and article_id = _article_id);
    else
        return null;
    end if;
end;
$$ language plpgsql;
