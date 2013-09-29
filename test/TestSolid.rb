#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "Solid"
  
##____________________________________________________________________________||
class TestSolid < Test::Unit::TestCase

  class MockGeometryManager
  end

  def setup  
    @geometryManager = MockGeometryManager.new
  end

  def test_one
    solid = Solid.new(@geometryManager, :Tubs)
  end

end

##____________________________________________________________________________||
