create view profiles_view as
select users.id,
       users.username,
       profiles.bio,
       profiles.image
from users
         join profiles on users.id = profiles.user_id;
