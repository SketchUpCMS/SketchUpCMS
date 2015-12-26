#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "LogicalPart"
  
##____________________________________________________________________________||
class TestLogicalPart < Test::Unit::TestCase

  def test_one
    logicalPart = LogicalPart.new(:LogicalPart)
  end

end

##____________________________________________________________________________||
