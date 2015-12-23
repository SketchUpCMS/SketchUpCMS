#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/lib")
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/gratr/lib")

require 'buildGeometryManager'
require 'buildDDLCallBacks'
require 'readXMLFiles'
require 'PartBuilder'

require "benchmark"
require 'graph_functions'

require 'gratr'
require 'gratr/dot'

##____________________________________________________________________________||
def cmsmain

  puts Benchmark::CAPTION
  puts Benchmark.measure {
    read_xmlfiles()
  }
  # puts Benchmark.measure {
  #   read_xmlfiles_from_cache()
  # }
  puts Benchmark.measure {
    draw_geom()
  }


end

##____________________________________________________________________________||
def draw_geom

  # all PosParts in the XML file
  graphAll = GRATR::DirectedPseudoGraph.new
  $posPartsManager.parts.each { |pp| graphAll.add_edge!(pp.parentName, pp.childName, pp.copyNumber) }

  topName = :"cms:CMSE"
  secondNames = [:"muonBase:MUON"]

  edgesToDelete = graphAll.edges.select { |e| e.source == topName && !secondNames.include?(e.target) }

  edgesToDelete.each { |e| graphAll.remove_edge!(e) }

  graphFromCMSE = subgraph_from(graphAll, topName)
  # p graphFromCMSE

  sub = subgraph_from_depth(graphFromCMSE, topName, 5)

  p sub 
  sub.write_to_graphic_file('pdf','visualize')

end


##____________________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__)) + '/'
  xmlfileListTest = [
       'Geometry_YB1N_sample.xml',
                    ]

  xmlfileList = xmlfileListTest

  xmlfileList.map! {|f| f = topDir + f }

  p xmlfileList

  geometryManager = buildGeometryManager()
  callBacks = buildDDLCallBacks(geometryManager)
  readXMLFiles(xmlfileList, callBacks)
end

##____________________________________________________________________________||
def read_xmlfiles_from_cache
  fillGeometryManager($geometryManager)
  $geometryManager.reload_from_cache
end

##____________________________________________________________________________||

cmsmain
