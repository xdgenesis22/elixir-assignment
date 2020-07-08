defmodule AssignmentWeb.Graphql.Resolvers.Weather do
  @moduledoc false

  @type resolver_output :: ok_output | error_output | plugin_output
  @type ok_output :: {:ok, any}
  @type error_output :: {:error, binary}
  @type plugin_output :: {:plugin, Absinthe.Plugin.t(), term}

  alias AssignmentWeb.Contexts.WeatherContext, as: WC

  def get_forecast_details(_, params, _) do
    :get_forecast_details
    |> WC.validate_params(params)
    |> WC.get_forecast_details()
  end

end
