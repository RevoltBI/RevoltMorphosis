# dbt Packages

dbt packages are the equivalent of libraries in other programming languages. They allow you to modularize and reuse dbt code, saving you from rewriting code that someone else has already perfected.

Packages are standalone dbt projects that can contain models, macros, tests, and other resources. When you add a package to your project, its resources become part of your own project.

## Common Use Cases

-   **Transforming SaaS Data**: Packages exist for transforming data from sources like Snowplow, Segment, AdWords, and Facebook Ads into a consistent, analytics-ready format.
-   **Utility Macros**: Packages like `dbt-utils` provide a collection of powerful macros for common tasks such as generating SQL, creating custom schema tests, and running audit queries.
-   **Tool-Specific Helpers**: Some packages provide models and macros for working with specific tools in your data stack, like Redshift or Stitch.

## `packages.yml` vs. `dependencies.yml`

You can manage both "package" and "project" dependencies in a `dependencies.yml` file.

-   **Package Dependencies**: Add source code from other dbt projects into your own, like a library.
-   **Project Dependencies**: A feature of dbt Mesh that allows for cross-project references.

If your project doesn't use Jinja in its package specifications, you can rename `packages.yml` to `dependencies.yml`. However, if you use Jinja for things like environment variables or Git tokens in private package specs, you should continue to use `packages.yml`.

-   **Use `dependencies.yml` for**:
    -   dbt Mesh and cross-project references.
    -   Managing both project dependencies and non-private dbt packages in one file.
-   **Use `packages.yml` for**:
    -   Only using packages from sources like dbt Hub.
    -   Including private packages that require Jinja for authentication.

## Adding a Package to Your Project

1.  Create a `packages.yml` or `dependencies.yml` file in your dbt project's root directory.
2.  Specify the packages you want to add.
3.  Run `dbt deps` to install the packages. They will be installed in the `dbt_packages` directory.

### Specifying Packages

#### dbt Hub (Recommended)

The [dbt Hub](https://hub.getdbt.com/) is a registry of public dbt packages.

```yaml
packages:
  - package: dbt-labs/snowplow
    version: 0.7.3
```

It's recommended to use a version range to avoid breaking changes:

```yaml
packages:
  - package: dbt-labs/snowplow
    version: [">=0.7.0", "<0.8.0"]
```

#### Git Packages

You can install packages directly from a Git repository.

```yaml
packages:
  - git: "https://github.com/dbt-labs/dbt-utils.git"
    revision: 0.9.2 # Can be a tag, branch, or commit hash
```

#### Private Packages

dbt supports private packages from GitHub and Azure DevOps natively if your dbt Cloud project is integrated with them.

```yaml
packages:
  - private: your-org/your-private-repo
    revision: "1.0.0"
```

For other set-ups, you can use an SSH key (CLI only) or a Git token embedded in the URL.

```yaml
# Git token method
packages:
  - git: "https://{{env_var('DBT_ENV_SECRET_GIT_CREDENTIAL')}}@github.com/dbt-labs/awesome_repo.git"
```

#### Local Packages

You can also reference a package on your local filesystem. This is useful for monorepos or for testing local changes to a package.

```yaml
packages:
  - local: relative/path/to/package
```

## Advanced Configuration

-   **Updating a Package**: Change the version or revision in `packages.yml` and run `dbt deps`.
-   **Uninstalling a Package**: Remove the package from `packages.yml` and either delete the corresponding folder in `dbt_packages/` or run `dbt clean` followed by `dbt deps`.
-   **Pinning Packages**: Running `dbt deps` creates a `package-lock.yml` file that pins each package to a specific commit. This ensures that your dependencies don't change unexpectedly. To upgrade to a newer version, run `dbt deps --upgrade`.
-   **Configuring Packages**: You can configure models, seeds, and variables from a package in your own `dbt_project.yml` file. These configurations will override the package's default settings.
