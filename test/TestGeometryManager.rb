#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "GeometryManager"
  
##____________________________________________________________________________||
class TestGeometryManager < Test::Unit::TestCase

  class MockPartBuilder
    def build(sectionName, inDDL, geometryManager)
      [sectionName, inDDL, geometryManager]
    end
  end

  class MockPartManager
    attr_reader :parts
    def initialize
      @parts = Array.new
    end
    def add part
      @parts << part
    end
  end

  def test_one

    materialsManager = MockPartManager.new

    partBuilder = MockPartBuilder.new

    geometryManager = GeometryManager.new
    geometryManager.materialsManager = materialsManager
    geometryManager.partBuilder = partBuilder

    geometryManager.add_entry(:MaterialSection, "sectionLabelA", "partNameA", {"name"=>"materials::materialA"}) 

    p materialsManager.parts
  end
  
end

##____________________________________________________________________________||
