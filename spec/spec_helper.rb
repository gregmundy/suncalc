require 'suncalc'

LAT = 50.5
LNG = 30.5
DATE = Time.utc(2013,03,05)

TEST_TIMES = { 
    :solar_noon => Time.utc(2013,03,05,10,10,57),
    :nadir => Time.utc(2013,03,04,22,10,57),
    :sunrise => Time.utc(2013,03,05,04,34,56),
    :sunset => Time.utc(2013,03,05,15,46,57),
    :sunrise_end => Time.utc(2013,03,05,04,38,19),
    :sunset_start => Time.utc(2013,03,05,15,43,34),
    :dawn => Time.utc(2013,03,05,04,02,17),
    :dusk => Time.utc(2013,03,05,16,19,36),
    :nautical_dawn => Time.utc(2013,03,05,03,24,31),
    :nautical_dusk => Time.utc(2013,03,05,16,57,22),
    :night_end => Time.utc(2013,03,05,02,46,17),
    :night => Time.utc(2013,03,05,17,35,36),
    :golden_hour_end => Time.utc(2013,03,05,05,19,01),
    :golden_hour => Time.utc(2013,03,05,15,02,52)
}

def near(val1, val2, margin)
    @compare = margin.nil? ? 0.000000000000001 : margin
    (val1 - val2).abs < @compare
end

def compare_time_string(expected, actual)
    expected.day.to_i == actual.day.to_i \
        && expected.month.to_i == actual.month.to_i \
        && expected.year.to_i == actual.year.to_i \
        && expected.hour.to_i == actual.hour.to_i \
        && expected.min.to_i == actual.min.to_i \
        && expected.sec.to_i == actual.sec.to_i
end


