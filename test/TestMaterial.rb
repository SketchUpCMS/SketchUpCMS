#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "Material"
  
##____________________________________________________________________________||
class TestRotation < Test::Unit::TestCase

  class MockGeometryManager
  end

  def setup  
    @geometryManager = MockGeometryManager.new
  end

  def test_one
   material = Material.new(@geometryManager, :Material)
  end

end

##____________________________________________________________________________||
