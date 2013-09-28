#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "RotationsManager"
  
##____________________________________________________________________________||
class TestRotationsManager < Test::Unit::TestCase

  class MockGeometryManager
  end

  def setup  
    @geometryManager = MockGeometryManager.new
    @rotationsManager = RotationsManager.new
  end

  def test_add

    part = Rotation.new(@geometryManager, :Rotation)
    part.name = :"DdBlNa:DdBlNa1306"

    @rotationsManager.add part

    assert_equal([part], @rotationsManager.parts)
    assert_equal({:"DdBlNa:DdBlNa1306" => part}, @rotationsManager.partsHash)

  end

  def test_add_unknown

    part = Rotation.new(@geometryManager, :UnknownRotation)
    part.name = :"DdBlNa:DdBlNa1306"

    ioerr = StringIO.new
    $stderr = ioerr
    @rotationsManager.add part
    $stderr = STDERR
    assert_equal("RotationsManager: Unknown part name: \"UnknownRotation\"\n", ioerr.string)

    assert_equal([], @rotationsManager.parts)

  end

  def test_get

    part = Rotation.new(@geometryManager, :Rotation)
    part.name = :"DdBlNa:DdBlNa1306"

    @rotationsManager.add part

    assert_equal(part, @rotationsManager.get(:"DdBlNa:DdBlNa1306"))
    assert_nil(@rotationsManager.get(:wrongname))

  end

end

##____________________________________________________________________________||
