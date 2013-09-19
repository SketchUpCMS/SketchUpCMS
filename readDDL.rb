#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/lib")
require 'ddlcallbacks'
require 'GeometryManager'

require "benchmark"
require 'defs'

##____________________________________________________________________________||
def cmsmain

  puts Benchmark::CAPTION
  puts Benchmark.measure {
    read_xmlfiles()
  }
  puts Benchmark.measure {
    draw_geom()
  }


end

##____________________________________________________________________________||
def draw_geom

  def create_array_to_draw graph, topName


    # GRATR::Digraph
    graphFromCMSE = subgraph_from(graph, topName)


    nameDepthTOB = [ {:name => :"tob:TOBLayer0", :depth => 2},
                     {:name => :"tob:TOBLayer1", :depth => 2},
                     {:name => :"tob:TOBLayer2", :depth => 2},
                     {:name => :"tob:TOBLayer3", :depth => 2},
                     {:name => :"tob:TOBLayer4", :depth => 2},
                     {:name => :"tob:TOBLayer5", :depth => 2},
                   ]

    # nameDepthTracker = nameDepthPixelBarrel + nameDepthPixelForward + nameDepthTIB + nameDepthTID + nameDepthTOB + nameDepthTEC
    nameDepthTracker = nameDepthTOB


    nameDepthList = nameDepthTracker

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
  graphAll = GRATR::Digraph.new
  $posPartsManager.parts.each { |pp| graphAll.add_edge!(pp.parentName, pp.childName) }

  topName = :"cms:CMSE"
  arrayToDraw = create_array_to_draw graphAll, topName

  p arrayToDraw
end


##____________________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__)) + '/'
  xmlfileListTest = [
        'GeometryTOB.xml'
                    ]

  xmlfileList = xmlfileListTest

  xmlfileList.map! {|f| f = topDir + f }

  p xmlfileList

  geometryManager = buildGeometryManager()
  callBacks = buildDDLCallBacks(geometryManager)
  readXMLFiles(xmlfileList, callBacks, geometryManager)
end

##____________________________________________________________________________||
def readXMLFiles(xmlfileList, callBacks, geometryManager)
  xmlfileList.each do |file| 
    p file
    geometryManager.xmlFilePath = file
    REXML::Document.parse_stream(File.new(file), callBacks)
  end
end

##____________________________________________________________________________||
def buildGeometryManager
  $materialsManager = MaterialsManager.new
  $rotationsManager = RotationsManager.new
  $geometryManager = GeometryManager.new
  $solidsManager = SolidsManager.new
  $logicalPartsManager = LogicalPartsManager.new
  $posPartsManager = PosPartsManager.new

  geometryManager = $geometryManager
  geometryManager.materialsManager = $materialsManager
  geometryManager.rotationsManager = $rotationsManager
  geometryManager.solidsManager = $solidsManager
  geometryManager.logicalPartsManager = $logicalPartsManager
  geometryManager.posPartsManager = $posPartsManager

  $materialsManager.geometryManager = geometryManager
  $rotationsManager.geometryManager = geometryManager
  $solidsManager.geometryManager = geometryManager
  $logicalPartsManager.geometryManager = geometryManager
  $posPartsManager.geometryManager = geometryManager

  geometryManager
end

##____________________________________________________________________________||

cmsmain
