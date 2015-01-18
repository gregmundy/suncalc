require 'suncalc'

LAT = 50.5
LNG = 30.5
DATE = Time.utc(2013,03,05)
SOLAR_NOON = Time.utc(2013,03,05,10,10,57)
NADIR = Time.utc(2013,03,04,22,10,57)
SUNRISE = Time.utc(2013,03,05,04,34,56)
SUNSET = Time.utc(2013,03,05,15,46,57)
SUNRISE_END = Time.utc(2013,03,05,04,38,19)
SUNSET_START = Time.utc(2013,03,05,15,43,34)
DAWN = Time.utc(2013,03,05,04,02,17)
DUSK = Time.utc(2013,03,05,16,19,36)
NAUTICAL_DAWN = Time.utc(2013,03,05,03,24,31)
NAUTICAL_DUSK = Time.utc(2013,03,05,16,57,22)
NIGHT_END = Time.utc(2013,03,05,02,46,17)
NIGHT = Time.utc(2013,03,05,17,35,36)
GOLDEN_HOUR_END = Time.utc(2013,03,05,05,19,01)
GOLDEN_HOUR = Time.utc(2013,03,05,15,02,52)

def near(val1, val2, margin)
    @compare = margin.nil? ? 0.000000000000001 : margin
    (val1 - val2).abs < @compare
end
