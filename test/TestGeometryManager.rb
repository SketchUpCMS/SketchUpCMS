#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "GeometryManager"
  
##____________________________________________________________________________||
class TestGeometryManager < Test::Unit::TestCase

  class MockPartBuilder
    def build(sectionName, inDDL, geometryManager)
      inDDL
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

  def setup
    @geometryManager = GeometryManager.new

    @materialsManager = MockPartManager.new
    @rotationsManager = MockPartManager.new
    @solidsManager = MockPartManager.new
    @logicalPartsManager = MockPartManager.new
    @posPartsManager = MockPartManager.new

    @geometryManager.materialsManager = @materialsManager
    @geometryManager.rotationsManager = @rotationsManager
    @geometryManager.solidsManager = @solidsManager
    @geometryManager.logicalPartsManager = @logicalPartsManager
    @geometryManager.posPartsManager = @posPartsManager

    @partBuilder = MockPartBuilder.new
    @geometryManager.partBuilder = @partBuilder

  end

  def test_add_entry

    @geometryManager.add_entry(:MaterialSection, "sectionLabelA", "partNameA", {"name"=>"materials::materialA"}) 

    assert_equal([{:sectionLabel=>:sectionLabelA, :partName=>:partNameA, :args=>{"name"=>"materials::materialA"}}], @materialsManager.parts)

  end
  
end

##____________________________________________________________________________||
