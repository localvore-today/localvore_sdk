defmodule LocalvoreSdk do
  use HTTPoison.Base

  @default_api_url "https://api.localvoretoday.com"
  @default_api_version "2016-10-28"

  @api_key Application.get_env(:localvore_sdk, :api_key)
  @domain Application.get_env(:localvore_sdk, :api_url, @default_api_url)
  @version Application.get_env(
    :localvore_sdk,
    :api_version,
    @default_api_version
  )

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

  # private

  def atomize_keys(value) when is_map(value) do
    for {key, val} <- value, into: %{} do
      {safe_to_atom(key), atomize_keys(val)}
    end
  end

  def atomize_keys(value) when is_list(value) do
    Enum.map(value, &atomize_keys/1)
  end

  def atomize_keys(value), do: value

  defp build_filter({column, query}) when is_list(query),
    do: "filter[#{column}]=#{Enum.join(query, ",")}"
  defp build_filter({column, query}), do: "filter[#{column}]=#{query}"

  defp build_query_string(filters) do
    filters
    |> Enum.map(&build_filter/1)
    |> Enum.join("&")
  end

  defp build_url(query, resource), do: resource <> "?" <> query

  defp process_request_headers(headers) do
    [
      {"Content-Type", "application/vnd.api+json"},
      {"Authorization", "Bearer #{@api_key}"},
    ] ++ headers
  end

  defp process_request_body(body) when is_map(body),
    do: Poison.encode!(body)
  defp process_request_body(body), do: body

  defp process_response_body(nil), do: nil
  defp process_response_body(""), do: nil
  defp process_response_body(body) do
    body
    |> Poison.decode!
    |> atomize_keys
  end

  defp process_url(url), do: [ @domain, @version, url ] |> Enum.join("/")

  defp safe_to_atom(input) when is_atom(input), do: input
  defp safe_to_atom(input) when is_bitstring(input), do: String.to_atom(input)
  defp safe_to_atom(input), do: input |> to_string |> safe_to_atom
end
