require 'test_helper'

class IndividualTest < ActiveSupport::TestCase
  test "01 - Individual New" do
    ## foo_bar

    individual = Individual.new
    individual.name = "Michael Jackson"

    assert individual.save

    assert_equal "Michael", individual.name_first
    assert_equal "Jackson", individual.name_last
    assert_equal "Michael Jackson", individual.name
  end
end
