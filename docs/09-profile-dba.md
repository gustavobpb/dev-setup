# Profile: DBA

**Script:** `steps/09-profile-dba.sh`
**Flag:** `--profiles dba`

Installs CLI database clients and a GUI tool for database administrators and backend developers who work with multiple database engines.

---

## Tools installed

### pgcli — PostgreSQL client

Installed via `pipx install pgcli`. A feature-rich PostgreSQL CLI with auto-completion, syntax highlighting, and multi-line query mode.

```bash
pgcli postgresql://user:pass@host/db
pgcli -h localhost -U postgres mydb
```

A configuration file is written to `~/.config/pgcli/config` with sensible defaults:

| Setting | Value |
|---------|-------|
| Syntax style | `monokai` |
| Vi mode | enabled |
| Row limit | 1000 |
| Multi-line mode | enabled (Enter twice to execute) |
| Output expand | `auto` (vertical when wide) |
| Timing | enabled |

### mycli — MySQL / MariaDB client

Installed via `pipx install mycli`. Same experience as pgcli but for MySQL-compatible databases.

```bash
mycli -u root -p mydb
mycli mysql://user:pass@host/db
```

### litecli — SQLite client

Installed via `pipx install litecli`. pgcli-style client for SQLite files.

```bash
litecli mydb.sqlite
```

### usql — Universal SQL client

Downloaded from `xo/usql` GitHub releases. A single binary that connects to PostgreSQL, MySQL, SQLite, Oracle, SQL Server, and more using a unified URL-based DSN syntax.

```bash
usql pg://user:pass@host/db
usql mysql://user:pass@host/db
usql sq://./myfile.sqlite
```

### mongosh — MongoDB Shell

Downloaded from the official MongoDB downloads (`downloads.mongodb.com`). The modern replacement for the `mongo` legacy shell.

```bash
mongosh "mongodb://localhost:27017"
mongosh "mongodb+srv://cluster.example.mongodb.net/mydb"
```

### redis-cli — Redis client

Installed via `apt-get install redis-tools` (from step 01, verified here). The standard Redis CLI included in the `redis-tools` apt package.

```bash
redis-cli -h localhost ping
redis-cli monitor
```

### DBeaver CE — GUI database manager

Installed via `sudo snap install dbeaver-ce`. A universal database management GUI supporting PostgreSQL, MySQL, SQLite, Oracle, SQL Server, MongoDB, Redis, and many more.

```bash
dbeaver
```

---

## Progress key

`09-profile-dba.sh` is written to `~/.dev-setup.progress` on success.
