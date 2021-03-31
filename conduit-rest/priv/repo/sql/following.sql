create function following(self bigint, other bigint) returns boolean as
$$
begin
    if self is null then
        return null;
    else
        return exists(select 1 from follows where source = self and target = other);
    end if;
end;
$$ language plpgsql
