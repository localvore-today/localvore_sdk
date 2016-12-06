# LocalvoreSdk

Provides a wrapper around HTTPoison for the Localvore API V2.

## Configuration

```elixir
config :localvore_sdk,
  api_version: "2016-10-28"
  api_key: "...",
  api_url: System.get_env("LVT_ELIXIR_API_URL")
```

## Installation

  1. Add `localvore_sdk` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        # ...
        {:localvore_sdk, git: "https://github.com/localvore-today/localvore_sdk"}
      ]
    end
    ```

  2. Ensure `localvore_sdk` is started before your application:

    ```elixir
    def application do
      [
        applications: [
          # ...
          :localvore_sdk
        ]
      ]
    end
    ```
