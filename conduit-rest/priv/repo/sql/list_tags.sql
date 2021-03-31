create function list_tags() returns setof text as
$$
select distinct(tag)
from tags;
$$ language sql
