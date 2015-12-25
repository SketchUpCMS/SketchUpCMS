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

  graphTopToSub = subgraph_from_to(graphAll, topName, [subName])

  graphSubToDepths = subgraph_from_depth(graphAll, subName, 5)

  graph = graphTopToSub + graphSubToDepths

  edge = graph.adjacent(:"mb1:MB1N", {:direction => :in, :type => :edges})[0]

  make_target_unique(graph, edge, :"mb1:MB1N#1")

  graph.write_to_graphic_file('pdf','graph')

  n_instances = n_paths(graph, topName)

  graph.topsort.each do |v|
    puts " %-25s %10d" % [v, n_instances[v]]
  end

end

##__________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__))
  xmlfileList = ['Geometry_YB1N_sample.xml']
  xmlfileList.map! {|f| f = File.join(topDir, f) }
  p xmlfileList
  geometryManager = buildGeometryManager()
  callBacks = buildDDLCallBacks(geometryManager)
  readXMLFiles(xmlfileList, callBacks)
end

##__________________________________________________________________||

cmsmain
