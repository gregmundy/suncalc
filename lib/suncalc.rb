require "suncalc/version"

module Suncalc
    # Shortcuts for easier to read equations
    RAD = Math::PI / 180
    DAY_MS = 1000 * 60 * 60 * 24
    J1970 = 2440588
    J2000 = 2451545
    E = RAD * 23.4397
    J0 = 0.0009

    # Date/time constants and conversions
    
    def self.to_julian(date)
        @time = date.to_f * 1000
        @time / DAY_MS - 0.5 + J1970
    end

    def self.from_julian(j)
        
    end

    def self.to_days(date)
        to_julian(date) - J2000
    end


    # General calculations for position

    def self.right_ascension(l, b)
        Math::atan2(Math::sin(l) * Math::cos(E) - Math::tan(b) * Math::sin(E), Math::cos(l))
    end

    def self.declination(l, b)
        Math::asin(Math::sin(b) * Math::cos(E) + Math::cos(b) * Math::sin(E) * Math::sin(l))
    end

    def self.azimuth(h, phi, dec)
        Math::atan2(Math::sin(h), Math::cos(h) * Math::sin(phi) - Math::tan(dec) * Math::cos(phi))
    end

    def self.altitude(h, phi, dec)
        Math::asin(Math::sin(phi) * Math::sin(dec) + Math::cos(phi) * Math::cos(dec) * Math::cos(h))
    end

    def self.sidereal_time(d, lw)
        RAD * (280.16 + 360.9856235 * d) - lw
    end

    # General sun calculations
    def self.solar_mean_anomaly(d)
        RAD * (357.5291 + 0.98560028 * d)
    end

    def self.ecliptic_longitude(m)
        c = RAD * (1.9148 * Math::sin(m) + 0.02 * Math::sin(2 * m) + 0.0003 * Math::sin(3 * m))
        p = RAD * 102.9372

        m + c + p + Math::PI
    end

    def self.sun_coords(d)
        @result = []
        sM = solar_mean_anomaly(d)
        eL = ecliptic_longitude(sM)


        { :dec => declination(eL, 0),
          :ra => right_ascension(eL, 0)
        }
    end

    # Calculate sun position for a given date and latitude/longitude
    def self.get_position(date, lat, lng)
        lw = RAD * -lng
        phi = RAD * lat
        d = to_days(date)
        c = sun_coords(d)
        h = sidereal_time(d, lw) - c[:ra]

        { :azimuth => azimuth(h, phi, c[:dec]),
          :altitude => altitude(h, phi, c[:dec])
        }
    end

    # Sun times configuration (angle, morning name, evening name)
    times = [
        [-0.833, 'sunrise', 'sunset'],
        [-0.3, 'sunrise_end', 'sunset_start'],
        [-6, 'dawn', 'dusk'],
        [-12, 'nautical_dawn', 'nautical_dusk'],
        [-18, 'night_end', 'night'],
        [6, 'golden_hour_end', 'golden_hour']
    ]

    def self.add_time(angle, rise_name, set_name)
        times << [angle, rise_name, set_name]
    end

    # Calculations for sun times
    def self.julian_cycle(d, lw)
        (d - J0 - lw / (2 * Math::PI)).round
    end

    def self.approx_transit(ht, lw, n)
        J0 + (ht + lw) / (2 * Math::PI) + n
    end

    def self.solar_transit_j(ds, m, l)
        J2000 + ds + 0.0053 * Math::sin(m) - 0.0069 * Math::sin(2 * l)
    end

    def self.hour_angle(h, phi, d)
    end

    # Returns set time for the given sun altitude
    def self.get_set_j(h, lw, phi, dec, n, m, l)
    end

    # Calculate sun times for a given date and latitude/longitude
    def self.get_times(date, lat, lng)
        lw = RAD * -lng
        phi = RAD * lat
        
        d = to_days(date)
        n = julian_cycle(d, lw)
        ds = approx_transit(0, lw, n)
        
        m = solar_mean_anomaly(ds)
        l = ecliptic_longitude(m)
        dec = declination(l, 0)

        jnoon = solar_transit_j(ds, m, l)

        puts 'jnoon = ' + jnoon.to_s


    end

    # Moon calculations
    def self.moon_coords(d)
    end

    def self.get_moon_position(date, lat, lng)
    end

    # Calculations for illumination parameters of the moon
    def get_moon_illumination(dat)
    end

    def hours_later(date, h)
    end

    def get_moon_times(date, lat, lng)
    end
end
