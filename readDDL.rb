#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require 'ddlcallbacks'
require 'GeometryManager'

require "benchmark"

##____________________________________________________________________________||
def cmsmain

  puts Benchmark::CAPTION
  puts Benchmark.measure {
    read_xmlfiles()
  }

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
def buildDDLCallBacks(geometryManager)

  materialSectionListener = SectionWithPartListener.new("MaterialSection", geometryManager)
  rotationSectionListener = RotationSectionListener.new(geometryManager)
  solidSectionListener = SectionWithPartListener.new("SolidSection", geometryManager)
  logicalPartSectionListener = SectionWithPartListener.new("LogicalPartSection", geometryManager)
  posPartSectionListener = SectionWithPartListener.new("PosPartSection", geometryManager)

  mainListenersDispatcher = HashListenersDispatcher.new
  mainListenersDispatcher.add_listner('MaterialSection', materialSectionListener)
  mainListenersDispatcher.add_listner('RotationSection', rotationSectionListener)
  mainListenersDispatcher.add_listner('SolidSection', solidSectionListener)
  mainListenersDispatcher.add_listner('LogicalPartSection', logicalPartSectionListener)
  mainListenersDispatcher.add_listner('PosPartSection', posPartSectionListener)

  callBacks = DDLCallbacks.new
  callBacks.listenersDispatcher = mainListenersDispatcher
  callBacks
end

##____________________________________________________________________________||

cmsmain
