defmodule AssignmentWeb.Graphql.Schema.WeatherTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  import_types Absinthe.Type.Custom

  alias AssignmentWeb.Graphql.Resolvers.Weather
  alias AssignmentWeb.Contexts.UtilityContext, as: UC

  @desc "Weather Forecast details"
  object :weather_forecast_details do
    field :date, :string, description: "Weather forecast date"
    field :sunrise, :string, description: "Weather forecast sunrise"
    field :sunset, :string, description: "Weather forecast sunset"
    field :temperature, :string, description: "Weather forecast temperature"
    field :feels_like, :string, description: "Weather forecast feels like"
    field :weather, list_of(:weather_details), description: "Weather forecast weather"
    field :daily, list_of(:daily_details), description: "Weather forecast daily"
  end

  @desc "Weather details"
  object :weather_details do
    field :main, :string, description: "Weather details main"
    field :description, :string, description: "Weather details description"
  end

  @desc "Daily details"
  object :daily_details do
    field :date, :string, description: "Daily details date"
    field :pressure, :string, description: "Daily details pressure"
    field :humidity, :string, description: "Daily details humidity"
    field :temperature, :temperature_details, description: "Daily details temperature"
    field :feels_like, list_of(:feels_like_details), description: "Daily details feels like"
  end

  @desc "Temperature details"
  object :temperature_details do
    field :day, :string, description: "Temperature details day"
    field :min, :string, description: "Temperature details min"
    field :max, :string, description: "Temperature details max"
    field :night, :string, description: "Temperature details night"
    field :evening, :string, description: "Temperature details evening"
    field :morning, :string, description: "Temperature details morning"
  end

  @desc "Feels like details"
  object :feels_like_details do
    field :day, :string, description: "Feels like details day"
    field :night, :string, description: "Feels like details night"
    field :evening, :string, description: "Feels like details evening"
    field :morning, :string, description: "Feels like details morning"
  end

  @desc "Input parameters"
  input_object :input_params do
    field :latitude, :string, description: "Latitude input"
    field :longitude, :string, description: "Longitude input"
  end

  @desc "Weather Forecast Queries"
  object :weather_queries do
    @desc "Returns weather forecast details"
    field :weather_forecast, :weather_forecast_details do
      @desc """
      - Card number of the member.
        - Possible error messages:
          * Invalid latitude
          * Invalid longitude
      """
      arg(:input, non_null(:input_params))

      resolve UC.handle_errors(&Weather.get_forecast_details/3)
    end
  end

end
