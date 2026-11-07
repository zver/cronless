**English** | [Русский](README.ru.md)

# Cronless

**Cronless** is a lightweight periodic task manager for Linux built on systemd timers.
It is a good fit for laptops and workstations that often go to sleep: missed runs are executed after the system wakes up.

---

## Features

- A lightweight cron replacement with no constant load on the system.
- Task management through the CLI: add, remove, run manually, view logs and more (see [Commands](#commands)).
- systemd timers with `Persistent=true`: tasks missed while the machine was asleep are run after it wakes up.
- Task execution report (`cronless report`):
  - number of runs over the selected period;
  - successful and failed runs;
  - maximum execution time.
- Metrics export in the [textfile collector](https://github.com/prometheus/node_exporter#textfile-collector) format for Prometheus node_exporter.

---

## Installation

### Debian and derivatives (one-liner)

```bash
curl -sL https://raw.githubusercontent.com/zver/cronless/refs/heads/master/scripts/install-latest-from-github | bash
```

The command downloads and runs a script that finds the deb package of the latest release on GitHub and installs it.

> You can review the script beforehand: [install-latest-from-github](https://github.com/zver/cronless/blob/master/scripts/install-latest-from-github).

Alternatively, download the deb package manually from the [releases page](https://github.com/zver/cronless/releases) and install it:

```bash
sudo apt install ./<file>.deb
```

### Ansible

See the [separate repository with the Ansible role](https://github.com/zver/ansible-cronless/).

---

## Usage

You can use the short name `cl` instead of `cronless`.

### Commands

| Command | Description |
| :------ | :---------- |
| `cronless add <name> "<command>" "<schedule>"` | Add a task |
| `cronless remove <name>` | Remove a task |
| `cronless list` | List tasks with their last result |
| `cronless edit <name>` | Open the task's launch script in an editor |
| `cronless logs <name>` | Show task logs |
| `cronless debug <name>` | Run the task in debug mode |
| `cronless run <name>` | Run the task manually by executing its script directly |
| `cronless start <name>` | Run the task manually through its systemd service: the run is recorded in journald and Prometheus metrics |
| `cronless enable <name>` | Enable scheduled execution of the task |
| `cronless disable <name>` | Disable scheduled execution of the task |
| `cronless report [-d <days>] [-n <count>]` | Show a task execution report (see [Report options](#report-options)) |
| `cronless update-node-exporter-textfile <path>` | Update the metrics file for node_exporter |

### Report options

The `cronless report` command accepts the following flags:

| Flag | Description |
| :--- | :---------- |
| `-d <days>` | Limits the number of days of log history searched for the report |
| `-n <count>` | Limits the number of task execution results included in the report |

### Examples

```bash
# Add a daily task
cronless add backup "/usr/local/bin/backup_db.sh" daily

# Add a weekly task that emails the cronless report
# (replace you@example.com with your address)
cronless add cronless-report-to-email "cronless report -d 7 -n 20 2>&1 | mail -s 'Cronless weekly report' you@example.com" weekly

# List tasks with their last result
cronless list

# Open the task's launch script in an editor
cronless edit backup

# Show task logs
cronless logs backup

# Run the task in debug mode
cronless debug backup

# Run the task manually by executing its script
cronless run backup

# Run the task manually through its systemd service,
# which in turn runs the executable script.
# This way the run is recorded in journald and Prometheus metrics
cronless start backup

# Disable scheduled execution of the task
cronless disable backup

# Enable scheduled execution of the task
cronless enable backup

# Get the weekly report: 7 days of log history, at most 20 execution results
cronless report -d 7 -n 20

# Email the report
cronless report -d 7 -n 20 | mail -s "Weekly Tasks Report" you@example.com

# Remove the task
cronless remove backup
```

---

## Schedule format

Schedules use the systemd [calendar events](https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#Calendar%20Events) format. A few examples:

| Value | Meaning |
| :---- | :------ |
| `daily` | Every day at 00:00 |
| `weekly` | Every Monday at 00:00 |
| `*-*-* 03:30:00` | Every day at 03:30 |
| `Mon *-*-* 02:00:00` | Every Monday at 02:00 |
| `*:0/30` | Every 30 minutes |
| `*-*-* *:0/15:00` | Every 15 minutes |

You can check an expression and see its next run time with:

```bash
systemd-analyze calendar "*-*-* *:0/15:00"
```

---

## Prometheus metrics

The `cronless update-node-exporter-textfile <path-to-metrics.prom>` command updates a file with cronless metrics in the [textfile collector](https://github.com/prometheus/node_exporter#textfile-collector) format.

To keep the file up to date automatically, add this command as a periodic task. For example, every 5 minutes (`$USER` is expanded by the shell when the task is added):

```bash
cronless add update-prometheus-textfile-for-cronless-tasks "cronless update-node-exporter-textfile /var/lib/node_exporter/textfile_collector/cronless.$USER.prom" "*-*-* *:0/5:00"
```

---

## Building the deb package yourself

Run from the repository root:

```bash
sudo apt install debhelper devscripts build-essential
dpkg-buildpackage -us -uc
```

The resulting package will appear in the parent directory.

---

## Project structure

- `debian/` — files for building the deb package;
- `scripts/` — the cronless scripts themselves.
