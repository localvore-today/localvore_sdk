defmodule LocalvoreSdk do
  use HTTPoison.Base

  @default_api_url "https://api.localvoretoday.com"
  @default_api_version "2016-10-28"

  def filter(resource, filters) do
    filters
    |> build_query_string
    |> build_url(resource)
    |> get
  end

  def filter!(resource, filters) do
    case filter(resource, filters) do
      {:ok, result} -> result
      {:error, reason} -> raise HTTPoison.Error, message: reason
    end
  end

  def process_request_body(body) when is_map(body), do: Poison.encode!(body)
  def process_request_body(body), do: body

  def process_request_headers(headers),
    do: [{"Content-Type", "application/vnd.api+json"}, {"Authorization", "Bearer #{api_key()}"}] ++ headers

  def process_request_options(options), do: Keyword.put(options, :follow_redirect, true)

  def process_response_body(nil), do: nil
  def process_response_body(""), do: nil
  def process_response_body(body), do: Poison.decode!(body, keys: :atoms)

  def process_url(url), do: Enum.join([domain(), api_version(), url], "/")

  defp api_key, do: Application.fetch_env!(:localvore_sdk, :api_key)
  defp api_version, do: Application.get_env(:localvore_sdk, :api_version, @default_api_version)

  defp build_filter({column, query}) do
    value =
      cond do
        is_list(query) -> Enum.join(query, ",")
        is_map(query) -> Poison.encode(query)
        true -> query
      end

    {"filter[#{column}]", value}
  end

  defp build_query_string(filters) do
    filters
    |> Enum.map(&build_filter/1)
    |> Enum.into(%{})
    |> URI.encode_query
  end

  defp build_url(query, resource), do: resource <> "?" <> query

  defp domain, do: Application.get_env(:localvore_sdk, :api_url, @default_api_url)
end
