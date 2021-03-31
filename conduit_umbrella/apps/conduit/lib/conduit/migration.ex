defmodule Conduit.Migration do
  def migrate do
    Postgrex.transaction(:db, fn conn ->
      Conduit.Events.Migration.schemas(conn)
      Conduit.Accounts.Migration.schemas(conn)
      Conduit.Social.Migration.schemas(conn)
      Conduit.Content.Migration.schemas(conn)

      Conduit.Events.Migration.types(conn)
      Conduit.Accounts.Migration.types(conn)
      Conduit.Social.Migration.types(conn)
      Conduit.Content.Migration.types(conn)

      Conduit.Events.Migration.tables(conn)
      Conduit.Accounts.Migration.tables(conn)
      Conduit.Social.Migration.tables(conn)
      Conduit.Content.Migration.tables(conn)

      Conduit.Accounts.Migration.indexes(conn)

      Conduit.Accounts.Migration.views(conn)
      Conduit.Social.Migration.views(conn)
      Conduit.Content.Migration.views(conn)

      Conduit.Accounts.Migration.functions(conn)
      Conduit.Social.Migration.functions(conn)
      Conduit.Content.Migration.functions(conn)

      Conduit.Accounts.Migration.triggers(conn)
      Conduit.Social.Migration.triggers(conn)
      Conduit.Content.Migration.triggers(conn)
    end)
  end

  def unsafe_drop() do
    Postgrex.transaction(:db, fn conn ->
      Postgrex.query(conn, "drop schema content cascade", [])
      Postgrex.query(conn, "drop schema social cascade", [])
      Postgrex.query(conn, "drop schema citext cascade", [])
      Postgrex.query(conn, "drop schema accounts cascade", [])
      Postgrex.query(conn, "drop schema events cascade", [])
    end)
  end
end
