$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe 'Numeric class is overloaded to calculate radians and degrees' do
	describe Numeric do
		it 'should give me 57.2957795 degrees for 1 radian' do
			1.to_deg.should == 57.2957795
		end
	end
end
