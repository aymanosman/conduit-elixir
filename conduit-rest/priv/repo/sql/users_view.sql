create view users_view as
select users.id,
       users.username,
       users.email,
       profiles.bio,
       profiles.image
from users
         join profiles on users.id = profiles.user_id;
