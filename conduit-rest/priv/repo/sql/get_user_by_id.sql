create function get_user_by_id(_id bigint) returns setof conduit_user as
'
    select users.id,
           users.username,
           users.email,
           profiles.bio,
           profiles.image
    from users
             join profiles on users.id = profiles.user_id
    where users.id = _id;
' language sql
