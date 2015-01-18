require 'spec_helper'

describe Suncalc do
    it "calculates azimuth and altitude for the given time and location" do
        @sun_pos = Suncalc.get_position(DATE, LAT, LNG)
        expect(near(@sun_pos[:azimuth], -2.5003175907168385, nil)).to be true
        puts @sun_pos[:azimuth]
    end

    it "can return sun phases for the given date and location" do
    end

    it "can return moon position data given time and location" do
    end

    it "can return fraction and angle of moon's illuminated limb and phase" do
    end

    it "can return moon rise and set times" do
    end
end
