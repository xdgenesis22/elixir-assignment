defmodule AssignmentWeb.Graphql.Schema do
  @moduledoc """
  This module defines the Tweeter GraphQL Schema.
  """

  use Absinthe.Schema

  import_types(AssignmentWeb.Graphql.Schema.WeatherTypes)

  query do
    import_fields(:weather_queries)
  end

end
