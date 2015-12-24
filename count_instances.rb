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

##__________________________________________________________________||
def cmsmain

  read_xmlfiles()
  draw_geom()

end

##__________________________________________________________________||
def draw_geom

  # all PosParts in the XML file
  graphAll = GRATR::DirectedPseudoGraph.new
  $posPartsManager.parts.each { |pp| graphAll.add_edge!(pp.parentName, pp.childName, pp.copyNumber) }

  topName = :"cms:CMSE"
  subName = :"muonBase:MBWheel_1N"

  graphTopToSub = subgraph_from_to(graphAll, topName, [subName])

  graphSubToDepths = subgraph_from_depth(graphAll, subName, 5)
  graph = graphTopToSub + graphSubToDepths

  graph.edges.each do |e|
    puts e
  end
  puts graph.edges.to_s

  puts "========"

  puts n_paths(graph, topName)

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
