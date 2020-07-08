defmodule AssignmentWeb.Contexts.WeatherContext do
  @moduledoc false

  use Tesla, only: [:get], docs: false
  alias Ecto.Changeset
  alias AssignmentWeb.Contexts.UtilityContext, as: UC

  def validate_params(:get_forecast_details, %{input: params}) do
    fields = %{
      longitude: :string,
      latitude: :string
    }

    keys = fields |> Map.keys()
    lat_regex = ~r/^(\+|-)?(?:90(?:(?:\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\.[0-9]{1,6})?))$/
    lon_regex = ~r/^(\+|-)?(?:180(?:(?:\.0{1,6})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\.[0-9]{1,6})?))$/

    {%{}, fields}
    |> Changeset.cast(params, keys)
    |> Changeset.validate_format(:latitude, lat_regex,
      message: "Invalid latitude. Allowed value must be a number between -90 to 90"
    )
    |> Changeset.validate_format(:longitude, lon_regex,
      message: "Invalid longitude. Allowed value must be a number between -180 to 180"
    )
    |> is_valid_changeset?()
  end

  defp is_valid_changeset?(changeset), do: {changeset.valid?, changeset}

  defp to_atom_map([], value), do: value
  defp to_atom_map([map | tails], value) do
    map = map |> to_atom_map()
    tails |> to_atom_map(value ++ [map])
  end

  defp to_atom_map(map) do
    map
    |> Map.new(fn({key, value}) ->
      {transform_string_keys(key), transform_value(key, value)}
    end)
  end

  defp transform_string_keys("dt"), do: :date
  defp transform_string_keys("temp"), do: :temperature
  defp transform_string_keys("eve"), do: :evening
  defp transform_string_keys("morn"), do: :morning
  defp transform_string_keys(string) when is_atom(string), do: string
  defp transform_string_keys(string), do: String.to_atom(string)

  defp transform_value("dt", value), do: value |> UC.transform_unix_to_date()
  defp transform_value("humidity", value), do: "#{value}%"
  defp transform_value(key, value) when key in ["sunrise", "sunset"], do: value |> UC.transform_unix_to_datetime()
  defp transform_value(_, value) when is_map(value), do: value |> to_atom_map()
  defp transform_value(_, value) when is_list(value), do: value |> to_atom_map([])
  defp transform_value(_, value), do: value

  def get_forecast_details({false, changeset}), do: {:error, changeset}
  def get_forecast_details({_, %{changes: %{latitude: lat, longitude: lon}}}) do
    response = Tesla.get!("https://api.openweathermap.org/data/2.5/onecall?lat=#{lat}&lon=#{lon}&exclude=hourly&appid=b43bb7b5f295a5bbd2431d924149d7a3")
    body = response.body |> Poison.decode!()
    current = body |> Map.get("current") |> to_atom_map()
    daily = body |> Map.get("daily") |> to_atom_map([])
    result = current |> Map.put(:daily, daily)

    {:ok, result}
  end

end
