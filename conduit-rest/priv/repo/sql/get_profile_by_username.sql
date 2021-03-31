create function get_profile_by_username(text, self bigint) returns setof profile as
'
    select username,
           bio,
           image,
           following(self, users.id)
    from profiles
             join users on user_id = users.id
    where username = $1;
' language sql
