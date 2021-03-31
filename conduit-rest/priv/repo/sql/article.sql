create type article as
(
    slug             text,
    title            text,
    description      text,
    body             text,
    "tagList"        text[],
    favorited        boolean,
    "favoritesCount" bigint,
    author           profile,
    "createdAt"      timestamp(0),
    "updatedAt"      timestamp(0)
);
