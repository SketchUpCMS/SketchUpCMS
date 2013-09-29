#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'
require "stringio"

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

    @geometryManager.add_entry(:MaterialSection, "GeometryExtended", "ElementaryMaterial", {"name"=>"materials:materialA"}) 
    @geometryManager.add_entry(:MaterialSection, "GeometryExtended", "ElementaryMaterial", {"name"=>"materials:materialB"}) 
    @geometryManager.add_entry(:MaterialSection, "GeometryExtended", "CompositeMaterial", {"name"=>"materials:materialC"}) 
    @geometryManager.add_entry(:RotationSection, "GeometryExtended", "Rotation", {"name"=>"rotations:rotationA"})
    @geometryManager.add_entry(:RotationSection, "GeometryExtended", "Rotation", {"name"=>"rotations:rotationB"})
    @geometryManager.add_entry(:RotationSection, "GeometryExtended", "ReflectionRotation", {"name"=>"rotations:rotationC"})
    @geometryManager.add_entry(:SolidSection, "GeometryExtended", "Polyhedra", {"name"=>"solids:polyhedraA"})
    @geometryManager.add_entry(:SolidSection, "GeometryExtended", "Tubs", {"name"=>"solids:tubsA"})
    @geometryManager.add_entry(:LogicalPartSection, "GeometryExtended", "LogicalPart", {"name"=>"tracker:Tracker"})
    @geometryManager.add_entry(:PosPartSection, "GeometryExtended", "PosPart", {"copyNumber"=>"1"})

    assert_equal([
                  {:sectionLabel=>:GeometryExtended, :partName=>:ElementaryMaterial, :args=>{"name"=>"materials:materialA"}},
                  {:sectionLabel=>:GeometryExtended, :partName=>:ElementaryMaterial, :args=>{"name"=>"materials:materialB"}},
                  {:sectionLabel=>:GeometryExtended, :partName=>:CompositeMaterial, :args=>{"name"=>"materials:materialC"}},
                 ], @materialsManager.parts)

    assert_equal([
                  {:sectionLabel=>:GeometryExtended, :partName=>:Rotation, :args=>{"name"=>"rotations:rotationA"}},
                  {:sectionLabel=>:GeometryExtended, :partName=>:Rotation, :args=>{"name"=>"rotations:rotationB"}},
                  {:sectionLabel=>:GeometryExtended, :partName=>:ReflectionRotation, :args=>{"name"=>"rotations:rotationC"}},
                 ], @rotationsManager.parts)

    assert_equal([
                  {:sectionLabel=>:GeometryExtended, :partName=>:Polyhedra, :args=>{"name"=>"solids:polyhedraA"}},
                  {:sectionLabel=>:GeometryExtended, :partName=>:Tubs, :args=>{"name"=>"solids:tubsA"}},
                 ], @solidsManager.parts)

    assert_equal([
                  {:sectionLabel=>:GeometryExtended, :partName=>:LogicalPart, :args=>{"name"=>"tracker:Tracker"}},
                 ], @logicalPartsManager.parts)

    assert_equal([
                  {:sectionLabel=>:GeometryExtended, :partName=>:PosPart, :args=>{"copyNumber"=>"1"}},
                 ], @posPartsManager.parts)

  end

  def test_wrong_section
    ioerr = StringIO.new
    $stderr = ioerr
    @geometryManager.add_entry(:NoSuchSection, "sectionLabelNoSuch", "partNameNoSuch", {"name"=>"nosuch:A"})
    $stderr = STDERR
    assert_equal("GeometryManager: Unknown section: \"NoSuchSection\"\n", ioerr.string)
  end
  
  def test_reload_from_cache

    @geometryManager.add_entry(:MaterialSection, "GeometryExtended", "ElementaryMaterial", {"name"=>"materials:materialA"}) 
    @geometryManager.add_entry(:MaterialSection, "GeometryExtended", "ElementaryMaterial", {"name"=>"materials:materialB"}) 
    @geometryManager.add_entry(:MaterialSection, "GeometryExtended", "CompositeMaterial", {"name"=>"materials:materialC"}) 
    @geometryManager.add_entry(:RotationSection, "GeometryExtended", "Rotation", {"name"=>"rotations:rotationA"})
    @geometryManager.add_entry(:RotationSection, "GeometryExtended", "Rotation", {"name"=>"rotations:rotationB"})
    @geometryManager.add_entry(:RotationSection, "GeometryExtended", "ReflectionRotation", {"name"=>"rotations:rotationC"})
    @geometryManager.add_entry(:SolidSection, "GeometryExtended", "Polyhedra", {"name"=>"solids:polyhedraA"})
    @geometryManager.add_entry(:SolidSection, "GeometryExtended", "Tubs", {"name"=>"solids:tubsA"})
    @geometryManager.add_entry(:LogicalPartSection, "GeometryExtended", "LogicalPart", {"name"=>"tracker:Tracker"})
    @geometryManager.add_entry(:PosPartSection, "GeometryExtended", "PosPart", {"copyNumber"=>"1"})

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

    @geometryManager.reload_from_cache


    assert_equal([
                  {:sectionLabel=>:GeometryExtended, :partName=>:ElementaryMaterial, :args=>{"name"=>"materials:materialA"}},
                  {:sectionLabel=>:GeometryExtended, :partName=>:ElementaryMaterial, :args=>{"name"=>"materials:materialB"}},
                  {:sectionLabel=>:GeometryExtended, :partName=>:CompositeMaterial, :args=>{"name"=>"materials:materialC"}},
                 ], @materialsManager.parts)

    assert_equal([
                  {:sectionLabel=>:GeometryExtended, :partName=>:Rotation, :args=>{"name"=>"rotations:rotationA"}},
                  {:sectionLabel=>:GeometryExtended, :partName=>:Rotation, :args=>{"name"=>"rotations:rotationB"}},
                  {:sectionLabel=>:GeometryExtended, :partName=>:ReflectionRotation, :args=>{"name"=>"rotations:rotationC"}},
                 ], @rotationsManager.parts)

    assert_equal([
                  {:sectionLabel=>:GeometryExtended, :partName=>:Polyhedra, :args=>{"name"=>"solids:polyhedraA"}},
                  {:sectionLabel=>:GeometryExtended, :partName=>:Tubs, :args=>{"name"=>"solids:tubsA"}},
                 ], @solidsManager.parts)

    assert_equal([
                  {:sectionLabel=>:GeometryExtended, :partName=>:LogicalPart, :args=>{"name"=>"tracker:Tracker"}},
                 ], @logicalPartsManager.parts)

    assert_equal([
                  {:sectionLabel=>:GeometryExtended, :partName=>:PosPart, :args=>{"copyNumber"=>"1"}},
                 ], @posPartsManager.parts)

  end

end

##____________________________________________________________________________||
