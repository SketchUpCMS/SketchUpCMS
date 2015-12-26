#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "PosPart"
  
##____________________________________________________________________________||
class TestPosPart < Test::Unit::TestCase

  def test_one
    posPart = PosPart.new(:PosPart)
  end

end

##____________________________________________________________________________||
