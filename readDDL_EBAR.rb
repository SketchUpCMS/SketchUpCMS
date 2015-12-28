#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/lib")
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/gratr/lib")

require 'buildGeometryManager'
require 'buildDDLCallBacks'
require 'readXMLFiles'

require 'graph_functions'
require 'graph_functions_DD'

require 'gratr'
require 'gratr/dot'

require "benchmark"

require 'LogicalPartInstance'

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

  vertices = Hash[$logicalPartsManager.parts.map { |p| [p.name, LogicalPartInstance.new($geometryManager, p)] } ]

  topName = :"cms:CMSE"

  subNames = [:"ebalgo:ESPM"]

  nameDepthList = [
    {:name => :"eregalgo:EFAW", :depth => 10},
    {:name => :"eregalgo:EBCOOL1", :depth => 3},
    {:name => :"eregalgo:EBCOOL2", :depth => 3},
    {:name => :"eregalgo:EBCOOL3", :depth => 3},
    {:name => :"eregalgo:EBCOOL4", :depth => 3},
  ]

  graphTopToSub = subgraph_from_to(graphAll, topName, subNames)

  names = nameDepthList.collect { |e| e[:name] }
  graphSubToNames = subgraph_from_to(graphAll, subNames, names)

  graphNamesToDepths = graphAll.class.new
  nameDepthList.each do |e|
    graphNamesToDepths = graphNamesToDepths + subgraph_from_depth(graphAll, e[:name], e[:depth])
  end

  graph = graphTopToSub + graphSubToNames + graphNamesToDepths

  edges = graph.adjacent(:"ebalgo:ESPM", {:direction => :in, :type => :edges})

  edges[18, 18].each do |e|
    graph.remove_edge! e
  end

  make_logicalPart_unique(graph, edges[0], vertices, true)
  graph = subgraph_trim_depth graph, :"ebalgo:ESPM#1", 2

  make_logicalPart_unique(graph, edges[1], vertices, true)
  graph = subgraph_trim_depth graph, :"ebalgo:ESPM#2", 3

  # make_logicalPart_unique(graph, edges[2], vertices, true)
  # graph = subgraph_trim_depth graph, :"ebalgo:ESPM#3", 4

  graph = subgraph_trim_depth graph, :"ebalgo:ESPM", 1

  graph = subgraph_from(graph, topName)

  n_instances = n_paths(graph, topName)

  graph.topsort.each do |v|
    puts " %-30s %10d   %s" % [v, n_instances[v], vertices[v].inspect]
  end

  graph.write_to_graphic_file('pdf','graph')

end

##__________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__))
  # xmlfileList = ['Geometry_YB1N_sample.xml']
  xmlfileList = ['GeometryExtended.xml']
  xmlfileList.map! {|f| f = File.join(topDir, f) }
  p xmlfileList
  geometryManager = buildGeometryManager()
  callBacks = buildDDLCallBacks(geometryManager)
  readXMLFiles(xmlfileList, callBacks)
end

##__________________________________________________________________||

cmsmain
