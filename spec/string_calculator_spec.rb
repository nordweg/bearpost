require 'string_calculator'

# "add" class method: given an empty string, it returns zero

describe StringCalculator do
  describe ".add" do
    context "given an empty string" do
      it "returns zero" do
        expect(StringCalculator.add("")).to eql(0)
      end
    end
  end
end

# EXPECTING OUTCOMES
# expect(...).to
# expect(...).not_to
#
# CONVENTIONS
#
# Class methods prefixed with a dot (".add")
# Instance methods prefixed with a dash ("#add").
#
# context is technically the same as describe,
# but is used in different places,
# to aid reading of the code.
#
#
# COMPARISONS
# expect(actual).to be >  expected
# expect(actual).to be >= expected
# expect(actual).to be <= expected
# expect(actual).to be <  expected
# expect(actual).to be_between(minimum, maximum).inclusive
# expect(actual).to be_between(minimum, maximum).exclusive
# expect(actual).to match(/expression/)
# expect(actual).to be_within(delta).of(expected)
# expect(actual).to start_with expected
# expect(actual).to end_with expected
#
# TYPES / CLASSES
# expect(actual).to be_instance_of(expected)
# expect(actual).to be_kind_of(expected)
# expect(actual).to respond_to(expected)
#
# TYPES / CLASSES
# expect(actual).to be_truthy    # passes if actual is truthy (not nil or true)
# expect(actual).to be true      # passes if actual == true
# expect(actual).to be_falsey    # passes if actual is falsy (nil or false)
# expect(actual).to be false     # passes if actual == false
# expect(actual).to be_nil       # passes if actual == nil
# expect(actual).to exist        # passes if actual.exist? is truthy
#
# COLLECTIONS
# expect(actual).to include(expected)
# expect(array).to match_array(expected_array)
#
# https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
#
