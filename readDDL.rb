#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/lib")
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/gratr/lib")

require 'buildGeometryManager'
require 'buildDDLCallBacks'
require 'readXMLFiles'
require 'PartBuilder'
require 'GeometryManager'

require "benchmark"
require 'graph_functions'

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

  def create_array_to_draw graph, topName


    # GRATR::Digraph
    graphFromCMSE = subgraph_from(graph, topName)

    nameDepthMB = [
                   {:name => :"muonBase:MBWheel_1N", :depth => 2},
                  ]

    nameDepthList = nameDepthMB

    names = nameDepthList.collect { |e| e[:name] }
    graphFromCMSEToNames = subgraph_from_to(graphFromCMSE, topName, names)

    graphFromNames = GRATR::Digraph.new
    nameDepthList.each do |e|
      graphFromNames = graphFromNames + subgraph_from_depth(graphFromCMSE, e[:name], e[:depth])
    end

    graphToDraw = graphFromCMSEToNames + graphFromNames

    # e.g. [:"cms:CMSE", :"tracker:Tracker", :"tob:TOB", .. ]
    toDrawNames = graphToDraw.size > 0 ? graphToDraw.topsort(topName) : [topName]

    toDrawNames
  end

  # all PosParts in the XML file
  graphAll = GRATR::DirectedPseudoGraph.new
  $posPartsManager.parts.each { |pp| graphAll.add_edge!(pp.parentName, pp.childName, pp.copyNumber) }

  # graphAll.edges.each do |e|
  #   puts e.label
  #   puts e.class
  # end
  # puts graphAll

  topName = :"cms:CMSE"
  arrayToDraw = create_array_to_draw graphAll, topName

  p arrayToDraw
end


##____________________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__)) + '/'
  xmlfileListTest = [
    'Geometry_YB1N_sample.xml'
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
