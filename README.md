# SunCalc

[![CI](https://github.com/gregmundy/suncalc/actions/workflows/ci.yml/badge.svg)](https://github.com/gregmundy/suncalc/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/suncalc.svg)](https://rubygems.org/gems/suncalc)

SunCalc is a Ruby library for computing the position of the sun and moon, the
phases of the moon, and the timing of sunlight events (sunrise, sunset,
golden hour, dawn, dusk, and so on) for any date and location.

It is a faithful port of [Vladimir Agafonkin](https://agafonkin.com/en)'s
[suncalc.js](https://github.com/mourner/suncalc) and tracks its formulas — most
of which come from the
[Astronomy Answers](https://aa.quae.nl/en/reken/zonpositie.html) site and Jean
Meeus' *Astronomical Algorithms*.

## Installation

Add to your Gemfile:

```ruby
gem 'suncalc'
```

Or install directly:

```sh
$ gem install suncalc
```

Requires Ruby 3.0 or newer. No runtime dependencies.

## Usage

All methods are module-level. Pass a `Time` (or anything that responds to
`#to_f` / `#year`/`#month`/`#day` as appropriate) along with the latitude and
longitude in decimal degrees.

### Sun position

```ruby
require 'suncalc'

pos = SunCalc.get_position(Time.utc(2013, 3, 5), 50.5, 30.5)
# => { :azimuth => -2.5003..., :altitude => -0.7000... }
```

| Key        | Description                                                       |
| ---------- | ----------------------------------------------------------------- |
| `azimuth`  | Sun azimuth in radians, measured from south, clockwise positive.  |
| `altitude` | Sun altitude above the horizon in radians.                        |

### Sun times

```ruby
times = SunCalc.get_times(Time.utc(2013, 3, 5), 50.5, 30.5)
times[:sunrise]    # => 2013-03-05 04:34:56 UTC
times[:golden_hour] # => 2013-03-05 15:02:52 UTC
```

The result hash contains the following keys:

| Key                | Event                                                  |
| ------------------ | ------------------------------------------------------ |
| `solar_noon`       | Sun is at its highest position.                        |
| `nadir`            | Sun is at its lowest position.                         |
| `sunrise`          | Top edge of the sun appears on the horizon.            |
| `sunrise_end`      | Bottom edge of the sun touches the horizon.            |
| `golden_hour_end`  | Morning golden hour ends (soft light).                 |
| `golden_hour`      | Evening golden hour starts.                            |
| `sunset_start`     | Bottom edge of the sun touches the horizon.            |
| `sunset`           | Top edge of the sun disappears below the horizon.      |
| `dusk`             | Evening civil twilight starts.                         |
| `nautical_dusk`    | Nautical twilight starts.                              |
| `night`            | Astronomical twilight ends; full darkness.             |
| `night_end`        | Astronomical twilight starts (the next morning).       |
| `nautical_dawn`    | Nautical dawn (morning nautical twilight starts).      |
| `dawn`             | Morning civil twilight starts.                         |

At polar latitudes events that do not occur on the requested date are
returned as `nil`. When both `:sunrise` and `:sunset` are `nil` the result
also contains either `:always_up => true` (midnight sun) or
`:always_down => true` (polar night), so callers can disambiguate without
recomputing the sun's altitude. Other events in the same call are still
returned normally — for example, on a midsummer day at 70°N you will get a
real `:solar_noon` Time and real `:golden_hour` boundaries alongside
`nil` for `:sunrise` and `:sunset`.

```ruby
times = SunCalc.get_times(Time.utc(2026, 6, 21), 69.6492, 18.9553)
times[:sunrise]   # => nil
times[:always_up] # => true
times[:solar_noon] # => 2026-06-21 11:13:08 UTC
```

#### Observer elevation

`get_times` accepts an optional fourth argument — the observer's height above
the horizon in meters — which advances sunrise and delays sunset accordingly:

```ruby
SunCalc.get_times(Time.utc(2013, 3, 5), 50.5, 30.5, 2000)[:sunrise]
# => 2013-03-05 04:25:07 UTC  (~10 minutes earlier than at sea level)
```

#### Custom times

You can register additional sun-altitude events, defined by the angle (in
degrees) the sun makes with the horizon:

```ruby
SunCalc.add_time(-4, :blue_hour_end, :blue_hour)
SunCalc.get_times(Time.now, 50.5, 30.5)[:blue_hour]
```

### Moon position

```ruby
moon = SunCalc.get_moon_position(Time.utc(2013, 3, 5), 50.5, 30.5)
# => {
#      :azimuth           => -0.9784...,
#      :altitude          =>  0.0146...,    # corrected for atmospheric refraction
#      :distance          => 364121.37...,  # km
#      :parallactic_angle => -0.5983...
#    }
```

### Moon illumination

```ruby
SunCalc.get_moon_illumination(Time.utc(2013, 3, 5))
# => { :fraction => 0.4848..., :phase => 0.7548..., :angle => 1.6733... }

SunCalc.get_moon_illumination  # defaults to the current time
```

| Key        | Description                                                                          |
| ---------- | ------------------------------------------------------------------------------------ |
| `fraction` | Illuminated fraction of the moon's disk (0 = new moon, 1 = full).                    |
| `phase`    | Moon phase as a 0-1 value: 0 = new, 0.25 = first quarter, 0.5 = full, 0.75 = last.   |
| `angle`    | Midpoint angle (radians) of the bright limb relative to celestial north.             |

### Moon rise and set times

```ruby
SunCalc.get_moon_times(Time.utc(2013, 3, 5), 50.5, 30.5)
# => { :set => 2013-03-05 08:44:40 UTC }
```

The returned hash may contain `:rise`, `:set`, both, neither, or `:alwaysUp` /
`:alwaysDown` if the moon does not cross the horizon during the day in
question.

By default the day boundary is computed in UTC. Pass `false` as the fourth
argument to use the host machine's local timezone instead:

```ruby
SunCalc.get_moon_times(Date.today, 50.5, 30.5, false)
```

## Accuracy

For the sun, results agree with NOAA's published values to within about a
minute under typical conditions. For the moon, accuracy is on the order of a
few arc-minutes for position and a few minutes for rise/set times — adequate
for any non-scientific use such as photography planning, calendar apps, or
games. If you need observatory-grade precision, use a JPL ephemeris instead.

## Credits

This library is a Ruby port of [Vladimir Agafonkin](https://agafonkin.com/en)'s
[suncalc.js](https://github.com/mourner/suncalc). All credit for the underlying
math belongs to him and the sources he draws from. Bugs in the Ruby port are
mine.

## Contributing

1. Fork the repository.
2. Create a topic branch (`git checkout -b my-feature`).
3. Add tests for your change and make sure `bundle exec rspec` passes.
4. Commit and push.
5. Open a pull request describing the change and its motivation.

## Releasing

Releases are cut by pushing a `v*` tag; GitHub Actions builds, tests, and
publishes the gem to RubyGems via trusted publishing. See
[RELEASING.md](RELEASING.md) for the full procedure.

## License

Released under the MIT License. See [LICENSE.txt](LICENSE.txt).
