create function register_user(_username text, _email citext, _password text, _bio text,
                              _image text) returns conduit_user as
'
    declare
        _id bigint;
    begin
        insert into users (username, email, password)
        values (_username, _email, _password)
        returning id into _id;
        insert
        into profiles (user_id, bio, image)
        values (_id, _bio, _image);
        return (_id, _username, _email, _bio, _image);
    end;
' language plpgsql
