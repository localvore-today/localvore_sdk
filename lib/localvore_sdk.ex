defmodule LocalvoreSdk do
  use HTTPoison.Base

  @default_api_url "https://api.localvoretoday.com"
  @default_api_version "2016-10-28"

  @domain Application.get_env(:localvore_sdk, :api_url, @default_api_url)
  @version Application.get_env(:localvore_sdk, :api_version, @default_api_version)

  def filter(resource, filters) do
    filters
    |> build_query_string
    |> build_url(resource)
    |> get
  end

  def filter!(resource, filters) do
    case filter(resource, filters) do
      {:ok, result} -> result
      {:error, reason} -> raise reason
    end
  end

  defp build_filter({column, query}), do: "filter[#{column}]=#{query}"

  defp build_query_string(filters) do
    filters
    |> Enum.map(&build_filter/1)
    |> Enum.join("&")
  end

  defp build_url(query, resource), do: resource <> "?" <> query

  defp domain, do: @domain

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
    [ domain(), version(), url ] |> Enum.join("/")
  end

  defp version, do: @api_version
end
