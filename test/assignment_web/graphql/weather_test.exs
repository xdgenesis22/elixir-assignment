defmodule AssignmentWeb.Graphql.WeatherTest do
  use AssignmentWeb.ConnCase
  @moduledoc false

  describe "get weather forecast" do
    test "with valid params" do
      query = """
        query {
          weatherForecast(input: {latitude: "52.3667", longitude: "4.8945"}){
            date
            sunrise
            sunset
            temperature
            feelsLike
            weather {
              main
              description
            }
            daily {
              date
              pressure
              humidity
              temperature {
                day
                min
                max
                night
                evening
                morning
              }
              feelsLike {
                day
                night
                evening
                morning
              }
            }
          }
        }
      """

      conn =
        post(
          Plug.Conn.put_req_header(build_conn(), "content-type", "plain/text"),
          "/graphiql",
          query
        )

      assert json_response(conn, 200)["data"]["weatherForecast"]
      # I can't assert the response due to result is always dynamic
    end

    test "with invalid latitude" do
      query = """
        query {
          weatherForecast(input: {latitude: "A", longitude: "1"}){
            date
          }
        }
      """

      conn =
        post(
          Plug.Conn.put_req_header(build_conn(), "content-type", "plain/text"),
          "/graphiql",
          query
        )

      assert json_response(conn, 200)["errors"] |> get_error_message("latitude") == "Invalid latitude. Allowed value must be a number between -90 to 90"
    end

    test "with invalid longitude" do
      query = """
        query {
          weatherForecast(input: {latitude: "1", longitude: "181"}){
            date
          }
        }
      """

      conn =
        post(
          Plug.Conn.put_req_header(build_conn(), "content-type", "plain/text"),
          "/graphiql",
          query
        )

      assert json_response(conn, 200)["errors"] |> get_error_message("longitude") == "Invalid longitude. Allowed value must be a number between -180 to 180"
    end
  end

  defp get_error_message(error, key) do
    error
    |> Enum.map(&(get_message(&1, key)))
    |> List.flatten()
    |> Enum.uniq()
    |> List.delete(nil)
    |> Enum.at(0)
  end

  defp get_message(map, key) do
    Enum.map(map, fn({_, value}) ->
      if value == key, do: map["message"]
    end)
  end

end
