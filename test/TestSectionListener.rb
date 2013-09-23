#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'test/unit'

require "DDLCallbacks/SectionListener"
  
##____________________________________________________________________________||
class TestSectionListener < Test::Unit::TestCase

  class MockGeometryManager
    attr_accessor :allEntries, :lastEntry
    def initialize
      @allEntries = [ ]
      @lastEntry = [ ]
    end

    def add_entry sectionName, sectionLabel, partName, args
      entry = [sectionName, sectionLabel, partName, args]
      @allEntries << entry
      @lastEntry = entry
    end

  end

  def test_callbacks
    geometryManager = MockGeometryManager.new
    swpListener = SectionListener.new("ASection", geometryManager)
    swpListener.listener_enter("ASection", {"label" => "asdf"})
    assert_equal([], geometryManager.lastEntry)
    swpListener.tag_start("A", {"name" => "a1"})
    assert_equal([], geometryManager.lastEntry)
    swpListener.tag_end("A")
    assert_equal([:ASection, "asdf", "A", {"name"=>"a1"}], geometryManager.lastEntry)
    swpListener.tag_start("A", {"name" => "a2"})
    assert_equal([:ASection, "asdf", "A", {"name"=>"a1"}], geometryManager.lastEntry)
    swpListener.tag_end("A")
    assert_equal([:ASection, "asdf", "A", {"name"=>"a2"}], geometryManager.lastEntry)
    swpListener.tag_start("A", {"name" => "a3"})
    assert_equal([:ASection, "asdf", "A", {"name"=>"a2"}], geometryManager.lastEntry)
    swpListener.tag_end("A")
    assert_equal([:ASection, "asdf", "A", {"name"=>"a3"}], geometryManager.lastEntry)
    swpListener.listener_exit("ASection")
    assert_equal([:ASection, "asdf", "A", {"name"=>"a3"}], geometryManager.lastEntry)
    assert_equal([[:ASection, "asdf", "A", {"name"=>"a1"}], [:ASection, "asdf", "A", {"name"=>"a2"}], [:ASection, "asdf", "A", {"name"=>"a3"}]], geometryManager.allEntries)
  end
  

end

##____________________________________________________________________________||
