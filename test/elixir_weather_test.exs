defmodule ElixirWeatherTest do
  use ExUnit.Case
  doctest ElixirWeather

  import ElixirWeather.CLI, only: [ parse_args: 1 ]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h",     "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "state value returned if one given" do
    assert parse_args(["CO"]) == { "CO" }
  end

  test "state is defaulted if no state given" do
    assert parse_args([]) == { "CO" }
  end
end
