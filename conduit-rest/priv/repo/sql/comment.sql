create type comment as
(
    id          bigint,
    body        text,
    "createdAt" timestamp(0),
    "updatedAt" timestamp(0),
    author      profile
);
