require 'spec_helper'

describe Suncalc do
    it "calculates azimuth and altitude for the given time and location" do
        @sun_pos = Suncalc.get_position(DATE, LAT, LNG)
        expect(near(@sun_pos[:azimuth], -2.5003175907168385, nil)).to be true 
        expect(near(@sun_pos[:altitude], -0.7000406838781611, nil)).to be true
    end

    it "can return sun phases for the given date and location" do
        @times = Suncalc.get_times(DATE, LAT, LNG)

        TEST_TIMES.each do |k,v|
            expect(@times[k].to_s).to eq(v.to_s)
        end
    end

    it "can return moon position data given time and location" do
        @moon_pos = Suncalc.get_moon_position(DATE, LAT, LNG)
        expect(near(@moon_pos[:azimuth], -0.9783999522438226, nil)).to be true
        expect(near(@moon_pos[:altitude], 0.006969727754891917, nil)).to be true
        expect(near(@moon_pos[:distance], 364121.37256256194, nil)).to be true
    end

    it "can return fraction and angle of moon's illuminated limb and phase" do
        @moon_illum = Suncalc.get_moon_illumination(DATE)
        expect(near(@moon_illum[:fraction], 0.4848068202456373, nil)).to be true
        expect(near(@moon_illum[:phase], 0.7548368838538762, nil)).to be true
        expect(near(@moon_illum[:angle], 1.6732942678578346, nil)).to be true
    end

    it "can return moon rise and set times" do
    end
end
