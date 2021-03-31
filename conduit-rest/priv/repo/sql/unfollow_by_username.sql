create function unfollow_by_username(self bigint, other text) returns profile as
'
    declare
        other_id bigint;
    begin
        select id
        into other_id
        from users
        where username = other;
        delete
        from follows
        where source = self
          and target = other_id;
        return get_profile_by_username(other, self);
    end;
' language plpgsql
