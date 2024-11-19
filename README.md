# bomctl-action

<center><img src=".github/bomctl.png" alt="Mose"></center>

[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/bomctl/bomctl-action/badge)](https://securityscorecards.dev/viewer/?uri=github.com/bomctl/bomctl-action)
[![Slack](https://img.shields.io/badge/slack-openssf/bomctl-white.svg?logo=slack)](https://slack.openssf.org/#bomctl)

__bomctl__ is format-agnostic Software Bill of Materials (SBOM) tooling, which is intended to bridge the gap between SBOM generation and SBOM analysis tools. It focuses on supporting more complex SBOM operations on multiple SBOM files that represent systems by being opinionated on only supporting the [NTIA minimum fields](https://www.ntia.doc.gov/files/ntia/publications/sbom_minimum_elements_report.pdf) or other fields supported by [protobom](https://github.com/protobom/protobom).

> [!NOTE]
> [bomctl](https://github.com/bomctl/bomctl) is an experimental project under active development. We'd love feedback on the concept, scope, and architecture!

This action installs `bomctl` and optionally:

- runs one or more `bomctl` commands
- exports the resulting SQLite database content as either a SQL script or JSON data

For a quick start guide on the usage of `bomctl`, please refer to <https://github.com/bomctl/bomctl-playground>.
For available `bomctl` releases, see <https://github.com/bomctl/bomctl/releases>.

## Usage

This action currently supports GitHub-hosted Linux, macOS and Windows runners (self-hosted runners may not work).

Add the following entry to your Github workflow YAML file:

```yaml
uses: bomctl/bomctl-action@v0.0.1
with:
  bomctl-version: v0.4.1 # optional
```

## Options

### `bomctl-version`

The version of `bomctl` to install. Can be a tagged release, commit SHA, branch name, or "latest".
A step using the `actions/setup-go` action must be executed before this action when specifying a
branch name or commit SHA.

<details>
<summary>Example</summary>

```yml
uses: bomctl/bomctl-action@v0.0.1
with:
  bomctl-version: v0.4.1
  # ...
```

</details>

### `install-dir`

Path of `bomctl` install directory (will be created if it doesn't exist). Defaults to `$HOME/.bomctl`.

<details>
<summary>Example</summary>

```yml
uses: bomctl/bomctl-action@v0.0.1
with:
  install-dir: ./.bin
  # ...
```

</details>

### `command`

Name of the command to run. See [the documentation](https://github.com/bomctl/bomctl)
for supported commands.

<details>
<summary>Example</summary>

```yml
uses: bomctl/bomctl-action@v0.0.1
with:
  command: fetch
  # ...
```

</details>

### `args`

Arguments that will be passed to the specified command. Defaults to `""`.

<details>
<summary>Example</summary>

```yml
uses: bomctl/bomctl-action@v0.0.1
with:
  command: fetch
  args: --verbose
    https://github.com/bomctl/bomctl/releases/download/v0.4.1/bomctl_0.4.1_darwin_arm64.tar.gz.cdx.json
    https://github.com/bomctl/bomctl/releases/download/v0.4.0/bomctl_0.4.0_linux_amd64.tar.gz.spdx.json
  # ...
```

</details>

### `database-dir`

Directory in which to create the SQLite `bomctl.db` file. Defaults to `.`.

<details>
<summary>Example</summary>

```yml
uses: bomctl/bomctl-action@v0.0.1
with:
  database-dir: ${{ github.workspace }}
  # ...
```

</details>

### `export-json`

Export contents of database after `bomctl` commands are run. The contents will be written to
`bomctl-export.json`. Defaults to `false`.

<details>
<summary>Example</summary>

```yml
uses: bomctl/bomctl-action@v0.0.1
with:
  export-json: true
  # ...
```

</details>

### `export-sql`

Export contents of database after `bomctl` commands are run. The contents will be written to
`bomctl-export.sql`, a script that can be used to recreate the database. Defaults to `false`.

<details>
<summary>Example</summary>

```yml
uses: bomctl/bomctl-action@v0.0.1
with:
  export-sql: true
  # ...
```

</details>

<!--
## Customization

See [the documentation](https://github.com/bomctl/bomctl) for supported commands.

### Inputs

The following inputs are optional:

| Input            | Description                                                                                      |
| :--------------- | :----------------------------------------------------------------------------------------------- |
| `bomctl-version` | `bomctl` version to install. Defaults to `latest`.                                               |
| `install-dir`    | Directory in which to install the `bomctl` binary. Defaults to `$HOME/.bomctl`.                  |
| `command`        | `bomctl` command to run. Defaults to `version`.                                                  |
| `args`           | Arguments to pass to the `bomctl` command specified. Defaults to `""`.                           |
| `database-dir`   | Directory in which to create the `bomctl.db` database file. Defaults to `.`.                     |
| `export-json`    | Export contents of database to `bomctl-export.json` and upload as artifact. Defaults to `false`. |
| `export-sql`     | Export contents of database to `bomctl-export.sql` and upload as artifact. Defaults to `false`.  |
-->

## Outputs

| Output           | Description                                                    |
| :--------------- | :------------------------------------------------------------- |
| `bomctl-version` | Resolved version of `bomctl` install if `latest` was provided. |

> Copyright © bomctl a Series of LF Projects, LLC
> For web site terms of use, trademark policy and other project policies
> please see <https://lfprojects.org>.
