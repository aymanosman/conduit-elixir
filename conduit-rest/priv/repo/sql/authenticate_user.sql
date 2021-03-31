create function authenticate_user(_email citext, _password text) returns conduit_user as
'
    declare
        _id bigint;
    begin
        select id
        into _id
        from users
        where email = _email
          and password = _password;
        if exists(select 1
                  from users
                  where email = _email
                    and password = _password) then
            return get_user_by_id(_id);
        else
            return null;
        end if;
    end;
' language plpgsql
