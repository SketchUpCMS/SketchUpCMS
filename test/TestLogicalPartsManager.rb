#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "LogicalPartsManager"
  
##____________________________________________________________________________||
class TestLogicalPartsManager < Test::Unit::TestCase

  def setup  
    @logicalPartsManager = LogicalPartsManager.new
  end

  def test_add

    part = LogicalPart.new(:LogicalPart)
    part.name = :"tracker:Tracker"

    @logicalPartsManager.add part

    assert_equal([part], @logicalPartsManager.parts)
    assert_equal({:"tracker:Tracker" => part}, @logicalPartsManager.partsHash)

  end

  def test_get

    part = LogicalPart.new(:LogicalPart)
    part.name = :"tracker:Tracker"

    @logicalPartsManager.add part

    assert_equal(part, @logicalPartsManager.get(:"tracker:Tracker"))
    assert_nil(@logicalPartsManager.get(:wrongname))

  end

end

##____________________________________________________________________________||
