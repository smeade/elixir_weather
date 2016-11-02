defmodule ElixirWeather.CLI do

  @default_state "CO"

  @moduledoc """
  Handle command line parsing and call various functions
  that result in a table of the recent weather observations
  from NOAA for a state.
  """

  def main(argv) do
    parse_args(argv)
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

      { _, [ statecode ], _ }
        -> { statecode }

      { _, [ ], _ }
        -> { @default_state }

      _ -> :help
    end
  end
end
