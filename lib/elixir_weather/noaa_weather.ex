defmodule ElixirWeather.NOAAWeather do
  # Not sure this is required by NOAA, but is a good idea
  # to let endpoints know who you are.
  @user_agent [ {"User-agent", "Meade scott@synapsoftware.com"} ]

  @weather_url Application.get_env(:elixir_weather, :noaa_url)

  def fetch(state_code) do
    @weather_url
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def handle_response({ :ok,  %{status_code: 200, body: body}}) do
    { :ok,    body }
  end

  def handle_response({ _,    %{status_code: _, body: body}}) do
    { :error, body }
  end
end
