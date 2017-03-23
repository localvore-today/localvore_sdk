defmodule LocalvoreSdk do
  use HTTPoison.Base

  @api_url "https://api.localvoretoday.com"
  @api_version "2016-10-28"

  def filter(resource, filters) do
    query = build_query_string(filters)
    get(resource <> "?" <> query)
  end

  # private

  defp build_query_string(filters) do
    filters
    |> Enum.map(fn({column, query}) -> "filter[#{column}]=#{query}" end)
    |> Enum.join("&")
  end

  defp domain do
    Application.get_env(:localvore_sdk, :api_url, @default_api_url)
  end

  defp process_request_headers(headers) do
    [
      {"Content-Type", "application/vnd.api+json"},
      {
        "Authorization",
        "Bearer #{Application.get_env(:localvore_sdk, :api_key)}"
      }
    ] ++ headers
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
    |> Exque.Utils.atomize_keys
  end

  defp process_url(url) do
    [ domain, version, url ] |> Enum.join("/")
  end

  defp version do
    Application.get_env(:localvore_sdk, :api_version, @current_api_version)
  end
end
