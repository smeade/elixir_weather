defmodule ElixirWeather.CLI do
  import SweetXml

  @default_state "CO"

  @moduledoc """
  Handle command line parsing and call various functions
  that result in a table of the recent weather observations
  from NOAA for a state.
  """

  def main(argv) do
    parse_args(argv)
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is a two character state code.

  Return a tuple of `{ statecode }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse_head(argv, switches: [ help: :boolean],
                                          aliases:  [ h:    :help   ])

    case parse do
      { [ help: true ], _, _ }
        -> :help

      { _, [ state_code ], _ }
        -> { state_code }

      { _, [ ], _ }
        -> { @default_state }

      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: elixir_weather [ state_code | "#{@default_state}" ]
    """
    System.halt(0)
  end

  def process({state_code}) do
    ElixirWeather.NOAAWeather.fetch_stations
    |> decode_response
    |> extract_stations
    |> filter_stations_for_state(state_code)
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from NOAA: #{message}"
    System.halt(2)
  end

  def extract_stations(wx_station_index) do
    wx_station_index |> xpath( ~x"//station"l, state: ~x"./state/text()", url: ~x"./xml_url/text()")
  end

  def filter_stations_for_state(stations, state_code) do
    charlist_state_code = String.to_charlist(state_code)
    for station <- stations, station.state == charlist_state_code, do: station
  end
end
