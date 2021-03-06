# ElixirWeather

## National Oceanic and Atmospheric Administration Weather Data

An exercise in Elixir programming suggested by [Dave Thomas](https://twitter.com/pragdave) in[Programming Elixir](https://pragprog.com/book/elixir13/programming-elixir-1-3).

In "Chapter 13: Organizing a Project", Dave leads us through the creation of an Elixir project. That chapter covers such items as project structure, the mix build tool, ExUnit testing framework and generating documentation. At the end of the chapter, Dave recommends this exercise:

> In the United States, the National Oceanic and Atmospheric Administration provides hourly XML feeds of conditions at 1,800 locations.7 For example, the feed for a small airport close to where I’m writing this is at http://w1.weather.gov/xml/current_obs/KDTO.xml. Write an application that fetches this data, parses it, and displays it in a nice format.

Here is my developer log for that exercise.

### Source data exploration

Let's look at the source data from NOAA.

A list of all stations is available at `http://w1.weather.gov/xml/current_obs/index.xml`.

It looks like this:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<wx_station_index>
        <credit>NOAA's National Weather Service</credit>
        <credit_URL>http://weather.gov/</credit_URL>
        <image>
                <url>http://weather.gov/images/xml_logo.gif</url>
                <title>NOAA's National Weather Service</title>
                <link>http://weather.gov</link>
        </image>
        <suggested_pickup>08:00 EST</suggested_pickup>
        <suggested_pickup_period>1140</suggested_pickup_period>
	<station>
		<station_id>CWAV</station_id>
		<state>AB</state>
            	<station_name>Sundre</station_name>
		<latitude>51.76667</latitude>
		<longitude>-114.68333</longitude>
            	<html_url>http://weather.noaa.gov/weather/current/CWAV.html</html_url>
            	<rss_url>http://weather.gov/xml/current_obs/CWAV.rss</rss_url>
            	<xml_url>http://weather.gov/xml/current_obs/CWAV.xml</xml_url>
	</station>

	<station>
		<station_id>CWBO</station_id>
		<state>AB</state>
            	<station_name>Brooks Automatic Weather Reporting System</station_name>
		<latitude>50.55</latitude>
		<longitude>-111.85</longitude>
            	<html_url>http://weather.noaa.gov/weather/current/CWBO.html</html_url>
            	<rss_url>http://weather.gov/xml/current_obs/CWBO.rss</rss_url>
            	<xml_url>http://weather.gov/xml/current_obs/CWBO.xml</xml_url>
	</station>
...
```

Here is a sample of one station:
```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<?xml-stylesheet href="latest_ob.xsl" type="text/xsl"?>
<current_observation version="1.0"
	 xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	 xsi:noNamespaceSchemaLocation="http://www.weather.gov/view/current_observation.xsd">
	<credit>NOAA's National Weather Service</credit>
	<credit_URL>http://weather.gov/</credit_URL>
	<image>
		<url>http://weather.gov/images/xml_logo.gif</url>
		<title>NOAA's National Weather Service</title>
		<link>http://weather.gov</link>
	</image>
	<suggested_pickup>15 minutes after the hour</suggested_pickup>
	<suggested_pickup_period>60</suggested_pickup_period>
	<location>Air Force Academy, CO</location>
	<station_id>KAFF</station_id>
	<latitude>38.96667</latitude>
	<longitude>-104.81667</longitude>
	<observation_time>Last Updated on Nov 1 2016, 3:58 pm MDT</observation_time>
        <observation_time_rfc822>Tue, 01 Nov 2016 15:58:00 -0600</observation_time_rfc822>
	<weather>Fair</weather>
	<temperature_string>60.0 F (15.5 C)</temperature_string>
	<temp_f>60.0</temp_f>
	<temp_c>15.5</temp_c>
	<relative_humidity>26</relative_humidity>
	<wind_string>Southeast at 13.8 MPH (12 KT)</wind_string>
	<wind_dir>Southeast</wind_dir>
	<wind_degrees>150</wind_degrees>
	<wind_mph>13.8</wind_mph>
	<wind_kt>12</wind_kt>
	<pressure_string>1009.0 mb</pressure_string>
	<pressure_mb>1009.0</pressure_mb>
	<pressure_in>29.94</pressure_in>
	<dewpoint_string>25.2 F (-3.8 C)</dewpoint_string>
	<dewpoint_f>25.2</dewpoint_f>
	<dewpoint_c>-3.8</dewpoint_c>
	<windchill_string>58 F (14 C)</windchill_string>
      	<windchill_f>58</windchill_f>
      	<windchill_c>14</windchill_c>
	<visibility_mi>10.00</visibility_mi>
 	<icon_url_base>http://forecast.weather.gov/images/wtf/small/</icon_url_base>
	<two_day_history_url>http://www.weather.gov/data/obhistory/KAFF.html</two_day_history_url>
	<icon_url_name>skc.png</icon_url_name>
	<ob_url>http://www.weather.gov/data/METAR/KAFF.1.txt</ob_url>
	<disclaimer_url>http://weather.gov/disclaimer.html</disclaimer_url>
	<copyright_url>http://weather.gov/disclaimer.html</copyright_url>
	<privacy_policy_url>http://weather.gov/notice.html</privacy_policy_url>
</current_observation>
```

### Output format exploration

The exercise doesn't specify an output format beyond displaying "it in a nice format". Let's let users filter by state and then show a row for each station in that state with current conditions.

```
station_id | location | temperature | wind_string | dewpoint_string | visibility_mi |  
-----------+----------+-------------+-------------+-----------------+-----------------+
...
```

### How Our Code Will Do It

This will be a command line application that retrieves, transforms and displays data. Let's lay out the flow:

fetch noaa data
  |> parse data
  |> filter by state
  |> format data into table

### Task: Use Mix to Create Our New Project

```
$ mix new elixir_weather
* creating README.md
* creating .gitignore
* creating mix.exs
* creating config
* creating config/config.exs
* creating lib
* creating lib/weather.ex
* creating test
* creating test/test_helper.exs
* creating test/weather_test.exs

Your Mix project was created successfully.
You can use "mix" to compile it, test it, and more:

    cd weather
    mix test

Run "mix help" for more commands.
```

### Transformation: Parse the Command Line

Like in the example project in the book, we want to keep the command line parsing separate from the main operation of the application, so the command line parsing will be in its own module.

* by convention: `ElixirWeather.CLI`
* main entry point of `main`
* put in `lib/elixir_weather/cli.ex`
* write tests

I followed the steps and pattern from the chapter walkthrough to create `lib/elixir_weather/cli.ex` and `test/elixir_weather_test.exs`.

### Transformation: Fetch from noaa

Following the example project in the book, let's fetch data from NOAA. I'm thinking the process will be like this:

If user asks for help:
* Output some help text.

Otherwise:
* Fetch a list of all stations.
* Filter out the stations in the desired US state.
* From those, build a list of xml api endpoints.
* For each of those, fetch the station's observations.

#### Respond to `-h`

```
$ mix run -e 'ElixirWeather.CLI.main(["-h"])'
usage: elixir_weather [ state_code | "CO" ]
```

#### Install dependency

We now need to decide what library to use to retrieve the XML from NOAA. [HTTPoison](https://github.com/edgurgel/httpoison) looks like a good start. [Install it](https://github.com/edgurgel/httpoison#installation).

After it's installed:

```Elixir
iex(4)>  HTTPoison.start                                                
{:ok, []}
iex(5)> HTTPoison.get!
```
### Fetch a list of all stations.

* Create new module, `NOAAWeather`.
* this will fetch data and handle responses

```Elixir
iex(1)> ElixirWeather.NOAAWeather.fetch_stations("CO")
{:ok, ...
```

### Parse the list.

We now parse the XML to build a list urls for stations in the state we are seeking. Erlang provides XML support via [`:xmerl`](http://erlang.org/doc/man/xmerl.html). Instead of using `:xmerl` directly, I've chosen to use a library wrapper that lets us more easily parse the XML.

[sweet_xml](https://github.com/awetzel/sweet_xml) looks like the most popular choice on hex.

* Add SweetXml dependency

### Fetch data for each station in our state

Hacking around in iex I discovered how to:
* parse the XML
* grab just state and xml_url values
* filter only the state we want
* fetch XML from each station's xml_url

```Elixir
iex(11)> result = doc |> xmap(
...(11)>   stations: [  
...(11)>     ~x"//wx_station_index/station"l,
...(11)>    state: ~x"./state/text()",
...(11)>    xml_url: ~x"./xml_url/text()"
...(11)>   ]
...(11)> )
%{stations: [%{state: 'AB',
  xml_url: 'http://weather.gov/xml/current_obs/CWAV.xml'},
%{state: 'AB', xml_url: 'http://weather.gov/xml/current_obs/CWBO.xml'}]}
iex(12)> result
%{stations: [%{state: 'AB',
  xml_url: 'http://weather.gov/xml/current_obs/CWAV.xml'},
%{state: 'AB', xml_url: 'http://weather.gov/xml/current_obs/CWBO.xml'}]}
iex(13)> result.stations
[%{state: 'AB', xml_url: 'http://weather.gov/xml/current_obs/CWAV.xml'},
%{state: 'AB', xml_url: 'http://weather.gov/xml/current_obs/CWBO.xml'}]
iex(20)> for station <- result.stations, station.state == 'AB', do: station      
[%{state: 'AB', xml_url: 'http://weather.gov/xml/current_obs/CWAV.xml'},
 %{state: 'AB', xml_url: 'http://weather.gov/xml/current_obs/CWBO.xml'}]
iex(21)> for station <- result.stations, station.state == 'ABC', do: station
[]
```
