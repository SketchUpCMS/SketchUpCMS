#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "MaterialsManager"
  
##____________________________________________________________________________||
class TestMaterialsManager < Test::Unit::TestCase

  class MockGeometryManager
  end

  def setup  
    @geometryManager = MockGeometryManager.new
    @materialsManager = MaterialsManager.new
  end

  def test_add

    part = Material.new(@geometryManager, :ElementaryMaterial)
    part.name = :"materials:Carbon"

    @materialsManager.add part

    assert_equal([part], @materialsManager.parts)
    assert_equal({:"materials:Carbon" => part}, @materialsManager.partsHash)

  end

  def test_get

    part = Material.new(@geometryManager, :Material)
    part.name = :"materials:Carbon"

    @materialsManager.add part

    assert_equal(part, @materialsManager.get(:"materials:Carbon"))
    assert_nil(@materialsManager.get(:wrongname))

  end

end

##____________________________________________________________________________||
