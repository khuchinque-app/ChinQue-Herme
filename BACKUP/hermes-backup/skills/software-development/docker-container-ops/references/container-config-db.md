# Container Config Database Schema

Keep all container configs in a local SQLite database so you can query
port maps, SSH commands, and known bugs without grepping files.

File: `containers.db` (in the project root)

## Schema

```sql
-- Core container records
CREATE TABLE containers (
    id          INTEGER PRIMARY KEY,
    name        TEXT NOT NULL,       -- root1, root2, ...
    dir         TEXT NOT NULL,       -- /container1, /container2, ...
    ssh_port    INTEGER NOT NULL,
    app_port    INTEGER NOT NULL,
    subnet      TEXT NOT NULL,
    bridge      TEXT,                -- br-xxx (docker bridge name)
    container_ip TEXT,
    base_image  TEXT DEFAULT 'ubuntu:22.04',
    hostname    TEXT,
    memory      TEXT DEFAULT '4G',
    cpu         TEXT DEFAULT '1.0',
    root_password TEXT DEFAULT 'hermes123',
    status      TEXT DEFAULT 'created',  -- created | running | stopped
    notes       TEXT
);

-- SSH / docker-exec commands per container
CREATE TABLE access_methods (
    id          INTEGER PRIMARY KEY,
    container_id INTEGER REFERENCES containers(id),
    method      TEXT NOT NULL,       -- ssh-outside | ssh-inside | docker-exec | bridge-ip
    command     TEXT NOT NULL,
    description TEXT
);

-- Known bugs with fix recipes
CREATE TABLE bugs (
    id          INTEGER PRIMARY KEY,
    title       TEXT NOT NULL,
    container_id INTEGER REFERENCES containers(id),
    symptom     TEXT NOT NULL,
    root_cause  TEXT NOT NULL,
    fix         TEXT NOT NULL,
    prevention  TEXT,
    severity    TEXT DEFAULT 'high'
);

-- Port mappings
CREATE TABLE ports (
    id          INTEGER PRIMARY KEY,
    container_id INTEGER REFERENCES containers(id),
    host_port   INTEGER NOT NULL,
    container_port INTEGER NOT NULL,
    protocol    TEXT DEFAULT 'tcp',
    service     TEXT
);

-- Volume mounts
CREATE TABLE volumes (
    id          INTEGER PRIMARY KEY,
    container_id INTEGER REFERENCES containers(id),
    host_path   TEXT NOT NULL,
    container_path TEXT NOT NULL,
    purpose     TEXT
);

-- Docker networks
CREATE TABLE networks (
    id          INTEGER PRIMARY KEY,
    name        TEXT NOT NULL,
    driver      TEXT DEFAULT 'bridge',
    subnet      TEXT NOT NULL,
    gateway     TEXT,
    container_id INTEGER REFERENCES containers(id)
);

-- Installed packages per container
CREATE TABLE packages (
    id          INTEGER PRIMARY KEY,
    container_id INTEGER REFERENCES containers(id),
    package     TEXT NOT NULL
);
```

## Views

```sql
-- Full container overview
CREATE VIEW v_summary AS
    SELECT c.name, c.status, c.subnet,
        GROUP_CONCAT(DISTINCT p.host_port || '->' || p.container_port || '/' || p.service, ', ') as port_map,
        GROUP_CONCAT(DISTINCT a.method || ': ' || a.command, '; ') as access
    FROM containers c
    LEFT JOIN ports p ON p.container_id = c.id
    LEFT JOIN access_methods a ON a.container_id = c.id
    GROUP BY c.id ORDER BY c.id;

-- All bugs with full details
CREATE VIEW v_bugs AS
    SELECT c.name as container, b.title, b.severity, b.symptom, b.root_cause, b.fix
    FROM bugs b JOIN containers c ON c.id = b.container_id
    ORDER BY b.severity DESC, b.id;
```

## Quick Queries

```bash
# See everything at a glance
sqlite3 containers.db "SELECT * FROM v_summary;"

# All bugs
sqlite3 containers.db "SELECT * FROM v_bugs;"

# SSH commands for a specific container
sqlite3 containers.db \
  "SELECT method, command FROM access_methods WHERE container_id=3;"

# Update status after bringing one online
sqlite3 containers.db \
  "UPDATE containers SET status='running' WHERE name='root2';"
```
