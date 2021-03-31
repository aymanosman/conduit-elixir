create function slugify(text) returns text as
$$
begin
    return regexp_replace(lower(trim(both from $1)), '\s+', '-', 'g');
end;
$$ language plpgsql;
