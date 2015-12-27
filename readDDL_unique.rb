#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/lib")
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/gratr/lib")

require 'buildGeometryManager'
require 'buildDDLCallBacks'
require 'readXMLFiles'

require 'graph_functions'

require 'gratr'
require 'gratr/dot'

require "benchmark"

##__________________________________________________________________||
def cmsmain

  lines = [ ]
  lines << Benchmark::CAPTION
  lines << Benchmark.measure { read_xmlfiles() }
  lines << Benchmark.measure { draw_geom() }
  puts lines

end

##__________________________________________________________________||
def draw_geom

  # all PosParts in the XML file
  graphAll = GRATR::DirectedPseudoGraph.new
  $posPartsManager.parts.each { |pp| graphAll.add_edge!(pp.parentName, pp.childName, pp) }

  topName = :"cms:CMSE"

  subName = :"muonBase:MBWheel_1N"

  nameDepthList = [
    {:name => :"mb1:MB1ChimHoneycombBox", :depth => 0},
    {:name => :"mb1:MB1ChimSuperLayerZ", :depth => 0},
    {:name => :"mb1:MB1ChimSuperLayerPhi", :depth => 0},
    {:name => :"mb1:MB1HoneycombBox", :depth => 0},

    # :"mb1:MB1SuperLayerZ"
    {:name => :"mb1:MB1SLZLayer_58Cells", :depth => 0},
    {:name => :"mb1:MB1SLZLayer_56Cells", :depth => 0},
    {:name => :"mb1:MB1SLZLayer_57Cells", :depth => 0},
    {:name => :"mb1:MB1SLZAlPlateInner", :depth => 0},
    {:name => :"mb1:MB1SLZAlPlateOuter", :depth => 0},

    # :"mb1:MB1SuperLayerPhi"
    {:name => :"mb1:MB1SLPhiLayer_48Cells", :depth => 0},
    {:name => :"mb1:MB1SLPhiLayer_50Cells", :depth => 0},
    {:name => :"mb1:MB1SLPhiLayer_49Cells", :depth => 0},
    {:name => :"mb1:MB1SLPhiAlPlateInner", :depth => 0},
    {:name => :"mb1:MB1SLPhiAlPlateOuter", :depth => 0},
  ]

  graphTopToSub = subgraph_from_to(graphAll, topName, [subName])

  names = nameDepthList.collect { |e| e[:name] }
  graphSubToNames = subgraph_from_to(graphAll, subName, names)

  graphNamesToDepths = graphAll.class.new
  nameDepthList.each do |e|
    graphNamesToDepths = graphNamesToDepths + subgraph_from_depth(graphAll, e[:name], e[:depth])
  end

  graph = graphTopToSub + graphSubToNames + graphNamesToDepths

  edge = graph.adjacent(:"mb1:MB1N", {:direction => :in, :type => :edges})[0]

  make_target_unique(graph, edge, :"mb1:MB1N#1")
  edgesToRemove = graph.adjacent(:"mb1:MB1N#1", {:direction => :out, :type => :edges})
  edgesToRemove.each { |e| graph.remove_edge! e }

  graph.write_to_graphic_file('pdf','graph')

  n_instances = n_paths(graph, topName)

  graph.topsort.each do |v|
    puts " %-30s %10d" % [v, n_instances[v]]
  end

end

##__________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__))
  xmlfileList = ['Geometry_YB1N_sample.xml']
  # xmlfileList = ['GeometryExtended.xml']
  xmlfileList.map! {|f| f = File.join(topDir, f) }
  p xmlfileList
  geometryManager = buildGeometryManager()
  callBacks = buildDDLCallBacks(geometryManager)
  readXMLFiles(xmlfileList, callBacks)
end

##__________________________________________________________________||

cmsmain
