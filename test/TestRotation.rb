#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "Rotation"
  
##____________________________________________________________________________||
class TestRotation < Test::Unit::TestCase

  class MockGeometryManager
  end

  def setup  
    @geometryManager = MockGeometryManager.new
  end

  def test_one
    rotation = Rotation.new(@geometryManager, :Rotation)
  end

end

##____________________________________________________________________________||
