defmodule Conduit.Events.Migration do
  def schemas(conn) do
    execute(conn, "create schema events")
  end

  def types(conn) do
    execute(conn, """
    create type events.event_type as enum (
      'user_registered',
      'user_updated',
      'article_created',
      'comment_added'
    )
    """)
  end

  def tables(conn) do
    execute(conn, """
    create table events.events (
      event_type events.event_type,
      data jsonb
    )
    """)
  end

  defp execute(conn, cmd) do
    Postgrex.query!(conn, cmd, [])
  end
end
