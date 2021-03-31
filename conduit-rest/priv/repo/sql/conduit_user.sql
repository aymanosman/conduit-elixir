create type conduit_user as
(
    id       bigint,
    username text,
    email    citext,
    bio      text,
    image    text
);
