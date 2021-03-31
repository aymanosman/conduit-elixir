create function follow_by_username(self bigint, other text) returns profile as
$$
declare
    other_id bigint;
begin
    select id
    into other_id
    from users
    where username = other;

    insert into follows (source, target)
    values (self, other_id);
    return get_profile_by_username(other, self);

exception
    when unique_violation then
        return get_profile_by_username(other, self);
end;
$$ language plpgsql
