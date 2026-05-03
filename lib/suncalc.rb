require "suncalc/version"

module SunCalc
    # Shortcuts for easier to read equations
    RAD = Math::PI / 180
    DAY_MS = 1000 * 60 * 60 * 24
    J1970 = 2440588
    J2000 = 2451545
    E = RAD * 23.4397
    J0 = 0.0009
    SDIST = 149598000
    HC = 0.133 * RAD

    TIMES = [
        [-0.833, :sunrise, :sunset],
        [-0.3, :sunrise_end, :sunset_start],
        [-6, :dawn, :dusk],
        [-12, :nautical_dawn, :nautical_dusk],
        [-18, :night_end, :night],
        [6, :golden_hour_end, :golden_hour]
    ]

    # Date/time constants and conversions
    
    def self.to_julian(date)
        (date.to_f * 1000) / DAY_MS - 0.5 + J1970
    end

    def self.from_julian(j)
        Time.at(((j + 0.5 - J1970) * DAY_MS)/1000).utc
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

    # Atmospheric refraction correction (Meeus formula 16.4). Input/output in
    # radians. Clamps h to >= 0 to avoid the div/0 singularity at h ≈ -0.0890.
    def self.astro_refraction(h)
        h = 0 if h < 0
        0.0002967 / Math.tan(h + 0.00312536 / (h + 0.08901179))
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

    def self.add_time(angle, rise_name, set_name)
        TIMES << [angle, rise_name, set_name]
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
        Math::acos((Math::sin(h) - Math::sin(phi) * Math::sin(d)) / (Math::cos(phi) * Math::cos(d)))
    end

    # Apparent angle of the horizon below the observer, in degrees, from a given
    # observer height in meters. Used to correct sun rise/set times for elevation.
    def self.observer_angle(height)
        -2.076 * Math.sqrt(height) / 60
    end

    # Returns set time for the given sun altitude
    def self.get_set_j(h, lw, phi, dec, n, m, l)
        w = hour_angle(h, phi, dec)
        a = approx_transit(w, lw, n)
        solar_transit_j(a, m, l)
    end

    # Calculate sun times for a given date and latitude/longitude. Optional
    # height (meters above the horizon) corrects for observer elevation.
    def self.get_times(date, lat, lng, height = 0)
        lw = RAD * -lng
        phi = RAD * lat
        dh = observer_angle(height)

        d = to_days(date)
        n = julian_cycle(d, lw)
        ds = approx_transit(0, lw, n)

        m = solar_mean_anomaly(ds)
        l = ecliptic_longitude(m)
        dec = declination(l, 0)

        jnoon = solar_transit_j(ds, m, l)

        result = {
            :solar_noon => from_julian(jnoon),
            :nadir => from_julian(jnoon - 0.5)
        }

        TIMES.each do |time|
            h0 = (time[0] + dh) * RAD
            begin
                jset = get_set_j(h0, lw, phi, dec, n, m, l)
                jrise = jnoon - (jset - jnoon)
                result[time[1]] = from_julian(jrise)
                result[time[2]] = from_julian(jset)
            rescue Math::DomainError
                # The sun never crosses this altitude on this date — polar
                # day or polar night for this particular event.
                result[time[1]] = nil
                result[time[2]] = nil
            end
        end

        # If sunrise/sunset don't occur, decide whether the sun was above the
        # horizon all day (always_up) or below it all day (always_down) by
        # looking at the altitude at solar noon (where hour angle = 0).
        if result[:sunrise].nil? && result[:sunset].nil?
            noon_altitude = altitude(0, phi, dec)
            if noon_altitude > 0
                result[:always_up] = true
            else
                result[:always_down] = true
            end
        end

        result
    end

    # Moon calculations
    def self.moon_coords(d)
        el = RAD * (218.316 + 13.176396 * d)
        m = RAD * (134.963 + 13.064993 * d)
        f = RAD * (93.272 + 13.229350 * d)

        l = el + RAD * 6.289 * Math::sin(m)
        b = RAD * 5.128 * Math::sin(f)
        dt = 385001 - 20905 * Math::cos(m)
        

        result = {
            :ra => right_ascension(l, b),
            :dec => declination(l, b),
            :dist => dt
        }

        result
    end

    def self.get_moon_position(date, lat, lng)
        lw = RAD * -lng
        phi = RAD * lat
        d = to_days(date)

        c = moon_coords(d)
        th = sidereal_time(d, lw) - c[:ra]
        h = altitude(th, phi, c[:dec])
        # Meeus formula 14.1
        pa = Math.atan2(Math.sin(th), Math.tan(phi) * Math.cos(c[:dec]) - Math.sin(c[:dec]) * Math.cos(th))

        {
            :azimuth => azimuth(th, phi, c[:dec]),
            :altitude => h + astro_refraction(h),
            :distance => c[:dist],
            :parallactic_angle => pa
        }
    end

    # Calculations for illumination parameters of the moon
    def self.get_moon_illumination(date = Time.now)
        d = to_days(date)
        s = sun_coords(d)
        m = moon_coords(d)

        phi = Math::acos(Math::sin(s[:dec]) * Math::sin(m[:dec]) + Math::cos(s[:dec]) * Math::cos(m[:dec]) * Math::cos(s[:ra] - m[:ra]))
        inc = Math::atan2(SDIST * Math::sin(phi), m[:dist] - SDIST * Math::cos(phi))
        angle = Math::atan2(Math::cos(s[:dec]) * Math::sin(s[:ra] - m[:ra]), Math::sin(s[:dec]) * Math::cos(m[:dec]) - Math::cos(s[:dec]) * Math::sin(m[:dec]) * Math::cos(s[:ra] - m[:ra]))

        result = {
            :fraction => (1 + Math::cos(inc)) / 2,
            :phase => 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / Math::PI,
            :angle => angle
        }

        result
    end

    def self.hours_later(date, h)
        Time.at(date.to_f + (h * (DAY_MS/1000)) / 24).utc 
    end

    def self.get_moon_times(date, lat, lng, in_utc = true)
        t = if in_utc
            Time.utc(date.year, date.month, date.day)
        else
            Time.local(date.year, date.month, date.day)
        end
        h0 = get_moon_position(t, lat, lng)[:altitude] - HC

        rise = false
        set = false
        ye = 0

        (1..24).step(2) do |i|
            h1 = get_moon_position(hours_later(t, i), lat, lng)[:altitude] - HC
            h2 = get_moon_position(hours_later(t, i + 1), lat, lng)[:altitude] - HC 

            a = (h0 + h2) / 2 - h1
            b = (h2 - h0) / 2
            xe = -b / (2 * a)
            ye = (a * xe + b) * xe + h1
            d = b * b - 4 * a * h1
            
            roots = 0

            if d >= 0
                dx = Math::sqrt(d) / (a.abs * 2)

                x1 = xe - dx
                x2 = xe + dx

                if x1.abs <= 1 
                    roots += 1
                end
                
                if x2.abs <= 1
                    roots += 1
                end

                if x1 < -1
                    x1 = x2
                end
            end

            if roots === 1
                if h0 < 0
                    rise = i + x1
                else
                    set = i + x1
                end
            elsif roots === 2
                rise = i + (ye < 0 ? x2 : x1)
                set = i + (ye < 0 ? x1 : x2)
            end
            
            break if rise and set

            h0 = h2
        end

        result = {}
        if rise
            result[:rise] = hours_later(t, rise)
        end
        
        if set
            result[:set] = hours_later(t, set)
        end

        if not rise and not set
            result[ye > 0 ? :alwaysUp : :alwaysDown] = true
        end

        result
    end
end
