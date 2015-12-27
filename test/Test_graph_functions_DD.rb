#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

$LOAD_PATH.push(File.join(File.dirname(File.dirname(__FILE__)), 'gratr', 'lib'))

require 'test/unit'
require "graph_functions_DD"

require 'gratr'
require 'gratr/dot'

##__________________________________________________________________||
class Test_graph_functions_DD < Test::Unit::TestCase

  class MockVertex
    attr_accessor :orig
    def initialize name
      @name = name
    end
    def initialize_copy(orig)
      @orig = orig
    end

  end

  def setup
    @graph_0 = GRATR::DirectedPseudoGraph[
      :"cms:CMSE", :"muonBase:MUON",
      :"muonBase:MUON", :"muonBase:MB",
      :"muonBase:MB", :"muonBase:MBWheel_2N",
      :"muonBase:MB", :"muonBase:MBWheel_1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1ChimN",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"mb1:MB1ChimN",:"mb1:MB1ChimHoneycombBox",
      :"mb1:MB1ChimN",:"mb1:MB1ChimSuperLayerZ",
      :"mb1:MB1ChimN",:"mb1:MB1ChimSuperLayerPhi",
      :"mb1:MB1ChimN",:"mb1:MB1ChimSuperLayerPhi",
      :"mb1:MB1N", :"mb1:MB1HoneycombBox",
      :"mb1:MB1N", :"mb1:MB1SuperLayerZ",
      :"mb1:MB1N", :"mb1:MB1SuperLayerPhi",
      :"mb1:MB1N", :"mb1:MB1SuperLayerPhi",
      :"mb1:MB1SuperLayerZ", :"mb1:MB1SLZAlPlateInner",
      :"mb1:MB1SuperLayerZ", :"mb1:MB1SLZAlPlateInner",
      :"mb1:MB1SuperLayerZ", :"mb1:MB1SLZAlPlateInner",
      :"mb1:MB1SuperLayerZ", :"mb1:MB1SLZAlPlateOuter",
      :"mb1:MB1SuperLayerZ", :"mb1:MB1SLZAlPlateOuter",
      :"mb1:MB1SuperLayerZ", :"mb1:MB1SLZLayer_57Cells",
      :"mb1:MB1SuperLayerZ", :"mb1:MB1SLZLayer_57Cells",
      :"mb1:MB1SuperLayerZ", :"mb1:MB1SLZLayer_58Cells",
      :"mb1:MB1SuperLayerZ", :"mb1:MB1SLZLayer_56Cells",
      :"mb1:MB1SuperLayerPhi", :"mb1:MB1SLPhiAlPlateInner",
      :"mb1:MB1SuperLayerPhi", :"mb1:MB1SLPhiAlPlateInner",
      :"mb1:MB1SuperLayerPhi", :"mb1:MB1SLPhiAlPlateInner",
      :"mb1:MB1SuperLayerPhi", :"mb1:MB1SLPhiAlPlateOuter",
      :"mb1:MB1SuperLayerPhi", :"mb1:MB1SLPhiAlPlateOuter",
      :"mb1:MB1SuperLayerPhi", :"mb1:MB1SLPhiLayer_49Cells",
      :"mb1:MB1SuperLayerPhi", :"mb1:MB1SLPhiLayer_49Cells",
      :"mb1:MB1SuperLayerPhi", :"mb1:MB1SLPhiLayer_50Cells",
      :"mb1:MB1SuperLayerPhi", :"mb1:MB1SLPhiLayer_48Cells",
    ]

    @graph_0_s = GRATR::DirectedPseudoGraph[
      :"cms:CMSE", :"muonBase:MUON",
      :"muonBase:MUON", :"muonBase:MB",
      :"muonBase:MB", :"muonBase:MBWheel_2N",
      :"muonBase:MB", :"muonBase:MBWheel_1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_2N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1ChimN",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"muonBase:MBWheel_1N", :"mb1:MB1N",
      :"mb1:MB1ChimN",:"mb1:MB1ChimHoneycombBox",
      :"mb1:MB1ChimN",:"mb1:MB1ChimSuperLayerZ",
      :"mb1:MB1ChimN",:"mb1:MB1ChimSuperLayerPhi",
      :"mb1:MB1ChimN",:"mb1:MB1ChimSuperLayerPhi",
      :"mb1:MB1N", :"mb1:MB1HoneycombBox",
      :"mb1:MB1N", :"mb1:MB1SuperLayerZ",
      :"mb1:MB1N", :"mb1:MB1SuperLayerPhi",
      :"mb1:MB1N", :"mb1:MB1SuperLayerPhi",
    ]

    @vertices_0_s = Hash[@graph_0_s.vertices.map { |v| [v, MockVertex.new(v)] }]

  end

  def test_basics
    @graph_0_s.write_to_graphic_file('pdf', 'graph')
  end

  def test_make_logicalPart_unique
    graph = @graph_0_s.class.new(@graph_0_s)
    vertices = @vertices_0_s.clone
    edge =  graph.edges.select { |e| e.source == :"muonBase:MBWheel_1N" and e.target == :"mb1:MB1N" }[0]
    make_logicalPart_unique(graph, edge, vertices)

    @graph_0_s.write_to_graphic_file('pdf', 'graph')
    graph.write_to_graphic_file('pdf', 'actual')

    assert_equal(@vertices_0_s.size + 1, vertices.size)
    assert_not_same vertices[:"mb1:MB1N"], vertices[:"mb1:MB1N#1"]
    assert_same vertices[:"mb1:MB1N"], vertices[:"mb1:MB1N#1"].orig

    assert_equal [
      [:"cms:CMSE", :"muonBase:MUON"],
      [:"muonBase:MUON", :"muonBase:MB"],
      [:"muonBase:MB", :"muonBase:MBWheel_2N"],
      [:"muonBase:MB", :"muonBase:MBWheel_1N"],
      [:"mb1:MB1ChimN", :"mb1:MB1ChimHoneycombBox"],
      [:"mb1:MB1ChimN", :"mb1:MB1ChimSuperLayerPhi"],
      [:"mb1:MB1ChimN", :"mb1:MB1ChimSuperLayerPhi"],
      [:"mb1:MB1ChimN", :"mb1:MB1ChimSuperLayerZ"],
      [:"mb1:MB1N", :"mb1:MB1HoneycombBox"],
      [:"mb1:MB1N", :"mb1:MB1SuperLayerPhi"],
      [:"mb1:MB1N", :"mb1:MB1SuperLayerPhi"],
      [:"mb1:MB1N", :"mb1:MB1SuperLayerZ"],
      [:"mb1:MB1N#1", :"mb1:MB1HoneycombBox"],
      [:"mb1:MB1N#1", :"mb1:MB1SuperLayerPhi"],
      [:"mb1:MB1N#1", :"mb1:MB1SuperLayerPhi"],
      [:"mb1:MB1N#1", :"mb1:MB1SuperLayerZ"],
      [:"muonBase:MBWheel_1N", :"mb1:MB1ChimN"],
      [:"muonBase:MBWheel_1N", :"mb1:MB1N"],
      [:"muonBase:MBWheel_1N", :"mb1:MB1N"],
      [:"muonBase:MBWheel_1N", :"mb1:MB1N#1"],
      [:"muonBase:MBWheel_2N", :"mb1:MB1N"],
      [:"muonBase:MBWheel_2N", :"mb1:MB1N"],
      [:"muonBase:MBWheel_2N", :"mb1:MB1N"],
      [:"muonBase:MBWheel_2N", :"mb1:MB1N"],
    ].sort, graph.edges.map { |e| [e.source, e.target] }.sort

  end

  def test_create_unique_symbol
    assert_equal :"mb1:MB1N#1", create_unique_symbol(:"mb1:MB1N", [:"mb1:MB1N"])
    assert_equal :"mb1:MB1N#2", create_unique_symbol(:"mb1:MB1N", [:"mb1:MB1N", :"mb1:MB1N#1"])
  end


end

##__________________________________________________________________||
