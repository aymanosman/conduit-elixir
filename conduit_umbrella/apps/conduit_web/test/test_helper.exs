ExUnit.start(capture_log: true)

Conduit.Migration.unsafe_drop()
Conduit.Migration.migrate()

DBConnection.Ownership.ownership_mode(:db, :manual, [])
