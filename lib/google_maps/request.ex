defmodule GoogleMaps.Request do
  @moduledoc false

  use HTTPoison.Base

  @doc """
  GET an endpoint with param keyword list
  """
  @spec get(String.t, keyword()) :: GoogleMaps.Response.t
  def get(endpoint, params) do
    params = Enum.map(params, &transform_param/1)
    get("#{endpoint}?#{URI.encode_query(params)}")
  end

  # HTTPoison callbacks.
  
  def process_url(url) do
    %{path: path, query: query} = URI.parse(url)
    "https://maps.googleapis.com/maps/api/#{path}/json?key=AIzaSyDnPCkQMDmfgneX6juLvQ6rjBF98lyG5T0&#{query}"
  end

  def process_response_body(body) do
    body |> Poison.decode!
  end

  # Helpers
  
  defp transform_param({:origin, {lat, lng}}) when is_number(lat) and is_number(lng) do
    {:origin, "#{lat},#{lng}"}
  end
  defp transform_param({:destination, {lat, lng}}) when is_number(lat) and is_number(lng) do
    {:destination, "#{lat},#{lng}"}
  end
  defp transform_param({:waypoints, "enc:" <> enc}) do
    {:waypoints, "enc:" <> enc}
  end
  defp transform_param({:waypoints, waypoints}) when is_list(waypoints) do
    transform_param({:waypoints, Enum.join(waypoints, "|")})
  end
  defp transform_param({:waypoints, waypoints}) do
    # @TODO: Encode the waypoints into encoded polyline.
    {:waypoints, "optimize:true|#{waypoints}"}
  end
  defp transform_param(param), do: param
end