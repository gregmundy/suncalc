require 'spec_helper'

describe SunCalc do
    it "calculates azimuth and altitude for the given time and location" do
        @sun_pos = SunCalc.get_position(DATE, LAT, LNG)
        expect(near(@sun_pos[:azimuth], -2.5003175907168385, nil)).to be true 
        expect(near(@sun_pos[:altitude], -0.7000406838781611, nil)).to be true
    end

    it "can return sun phases for the given date and location" do
        @times = SunCalc.get_times(DATE, LAT, LNG)

        TEST_TIMES.each do |k,v|
            expect(@times[k].to_s).to eq(v.to_s)
        end
    end

    it "shifts sunrise/sunset earlier and later when an observer height is supplied" do
        sea_level = SunCalc.get_times(DATE, LAT, LNG)
        elevated = SunCalc.get_times(DATE, LAT, LNG, 2000)

        expect(elevated[:sunrise]).to be < sea_level[:sunrise]
        expect(elevated[:sunset]).to be > sea_level[:sunset]
        # Reference values from upstream suncalc.js v1.9.0 with height=2000
        expect(elevated[:sunrise].utc.strftime("%H:%M:%S")).to eq("04:25:07")
        expect(elevated[:sunset].utc.strftime("%H:%M:%S")).to eq("15:56:46")
    end

    it "can return moon position data given time and location" do
        @moon_pos = SunCalc.get_moon_position(DATE, LAT, LNG)
        expect(near(@moon_pos[:azimuth], -0.9783999522438226, nil)).to be true
        expect(near(@moon_pos[:altitude], 0.014551482243892251, nil)).to be true
        expect(near(@moon_pos[:distance], 364121.37256256194, nil)).to be true
        expect(near(@moon_pos[:parallactic_angle], -0.5983211760423401, nil)).to be true
    end

    it "applies astronomical refraction correctly without blowing up below the horizon" do
        # The old refraction formula had a singularity near h = -0.089 rad.
        # The corrected formula clamps h to >= 0 before applying refraction.
        result = SunCalc.astro_refraction(-0.5)
        expect(result.finite?).to be true
        expect(result).to eq(SunCalc.astro_refraction(0))
    end

    it "can return fraction and angle of moon's illuminated limb and phase" do
        @moon_illum = SunCalc.get_moon_illumination(DATE)
        expect(near(@moon_illum[:fraction], 0.4848068202456373, nil)).to be true
        expect(near(@moon_illum[:phase], 0.7548368838538762, nil)).to be true
        expect(near(@moon_illum[:angle], 1.6732942678578346, nil)).to be true
    end

    it "defaults moon illumination to the current time when no date is given" do
        result = SunCalc.get_moon_illumination
        expect(result[:fraction]).to be_between(0, 1)
        expect(result[:phase]).to be_between(0, 1)
    end

    it "can return moon rise and set times" do
        @moon_times = SunCalc.get_moon_times(DATE, LAT, LNG)
        # On 2013-03-05 UTC at this location the moon only sets within the day
        # (rise was the previous evening). Match upstream suncalc.js v1.9.0.
        expect(@moon_times[:set].to_i).to be_within(60).of(MOON_SET.to_i)
        expect(@moon_times[:rise]).to be_nil
    end

    it "honors the in_utc flag for moon times" do
        # Forcing UTC must not depend on the host machine's local timezone.
        utc_times = SunCalc.get_moon_times(DATE, LAT, LNG, true)
        expect(utc_times[:set].to_i).to be_within(60).of(MOON_SET.to_i)
    end
end
