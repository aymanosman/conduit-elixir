create function get_comment_by_id(_comment_id bigint, _user_id bigint) returns setof comment as
$$
begin
    return query select comments.id,
                        comments.body,
                        comments."createdAt",
                        comments."updatedAt",
                        (username, bio, image, following(_user_id, users.id))::profile as author
                 from comments
                          join users on comments.author_id = users.id
                          join profiles on users.id = profiles.user_id
                          join articles on comments.article_id = articles.id
                 where comments.id = _comment_id;
end;
$$ language plpgsql;
