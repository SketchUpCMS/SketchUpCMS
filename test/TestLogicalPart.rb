#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "LogicalPart"
  
##____________________________________________________________________________||
class TestLogicalPart < Test::Unit::TestCase

  class MockGeometryManager
  end

  def setup  
    @geometryManager = MockGeometryManager.new
  end

  def test_one
    logicalPart = LogicalPart.new(@geometryManager, :LogicalPart)
  end

end

##____________________________________________________________________________||
