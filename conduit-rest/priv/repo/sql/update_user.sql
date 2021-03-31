create function update_user(_id bigint, _email citext, _bio text, _image text, _username text,
                            _password text) returns conduit_user as
'
    begin
        update users
        set email    = coalesce(_email, email),
            username = coalesce(_username, username),
            password = coalesce(_password, password)
        where id = _id;
        update profiles
        set bio   = coalesce(_bio, bio),
            image = coalesce(_image, image)
        where user_id = _id;
        return get_user_by_id(_id);
    end;
' language plpgsql
