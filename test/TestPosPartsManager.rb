#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "PosPartsManager"
  
##____________________________________________________________________________||
class TestPosPartsManager < Test::Unit::TestCase

  class MockGeometryManager
  end

  def setup  
    @geometryManager = MockGeometryManager.new
    @posPartsManager = PosPartsManager.new
  end

  def test_add

    part = PosPart.new(@geometryManager, :PosPart)
    part.parentName = :"tobmodule0:TOBModule0"
    part.childName = :"tobrod1l:TOBRodCentral1L"
    part.copyNumber = 6

    @posPartsManager.add part

    assert_equal([part], @posPartsManager.parts)
    assert_equal({:"tobmodule0:TOBModule0" => [part]}, @posPartsManager.partsHashByParent)
    assert_equal({:"tobrod1l:TOBRodCentral1L" => [part]}, @posPartsManager.partsHashByChild)
    assert_equal({[:"tobmodule0:TOBModule0", :"tobrod1l:TOBRodCentral1L"] => [part]}, @posPartsManager.partsHashByParentChild)
    assert_equal({[:"tobmodule0:TOBModule0", :"tobrod1l:TOBRodCentral1L", 6] => [part]}, @posPartsManager.partsHashByParentChildCopy)

  end

  def test_get

    part = PosPart.new(@geometryManager, :PosPart)
    part.parentName = :"tobmodule0:TOBModule0"
    part.childName = :"tobrod1l:TOBRodCentral1L"
    part.copyNumber = 6

    @posPartsManager.add part

    assert_equal([part], @posPartsManager.getByParent(:"tobmodule0:TOBModule0"))
    assert_equal([part], @posPartsManager.getByChild(:"tobrod1l:TOBRodCentral1L"))
    assert_equal([part], @posPartsManager.getByParentChild(:"tobmodule0:TOBModule0", :"tobrod1l:TOBRodCentral1L"))
    assert_equal([part], @posPartsManager.getByParentChildCopy(:"tobmodule0:TOBModule0", :"tobrod1l:TOBRodCentral1L", 6))

    assert_equal([], @posPartsManager.getByParent(:wrongname))
    assert_equal([], @posPartsManager.getByChild(:wrongname))
    assert_equal([], @posPartsManager.getByParentChild(:wrongname, :wrongname))
    assert_equal([], @posPartsManager.getByParentChildCopy(:wrongname, :wrongname, :wrongnumber))

  end

end

##____________________________________________________________________________||
