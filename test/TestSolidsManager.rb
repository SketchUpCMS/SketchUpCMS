#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "SolidsManager"
  
##____________________________________________________________________________||
class TestSolidsManager < Test::Unit::TestCase

  class MockGeometryManager
  end

  def setup  
    @geometryManager = MockGeometryManager.new
    @solidsManager = SolidsManager.new
  end

  def test_add

    part = Solid.new(@geometryManager, :Solid)
    part.name = :"tob:TOBAxService_8C"

    @solidsManager.add part

    assert_equal([part], @solidsManager.parts)
    assert_equal({:"tob:TOBAxService_8C" => part}, @solidsManager.partsHash)

  end

  def test_get

    part = Solid.new(@geometryManager, :Solid)
    part.name = :"tob:TOBAxService_8C"

    @solidsManager.add part

    assert_equal(part, @solidsManager.get(:"tob:TOBAxService_8C"))
    assert_nil(@solidsManager.get(:wrongname))

  end

end

##____________________________________________________________________________||
