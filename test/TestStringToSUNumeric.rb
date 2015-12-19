#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "stringToSUNumeric"

##__________________________________________________________________||
class TestStringToSUNumeric < Test::Unit::TestCase

  def test_integer
    assert_equal 10, stringToSUNumeric('10')
  end

  def test_float
    assert_equal 20.345, stringToSUNumeric('20.345')
  end

  def test_end_with_period
    assert_equal 10, stringToSUNumeric('10.')
  end

  #

end

##__________________________________________________________________||
