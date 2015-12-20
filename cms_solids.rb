# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

require File.dirname(__FILE__) + '/sitecfg.rb'

require 'gratr'

require 'buildGeometryManager'
require 'buildDDLCallBacks'
require 'readXMLFiles'
require 'PartBuilder'
require 'solids'
require 'EntityDisplayer.rb'
require 'defs.rb'

##____________________________________________________________________________||
def cmsmain


  read_xmlfiles
  # read_xmlfiles_from_cache


  draw_solids

end

##____________________________________________________________________________||
def draw_solids

  entityDisplayer = EntityDisplayer.new('solids', 100.m, 0, 0)

  partNameCounter = { }
  totalCounter = 0

  $solidsManager.parts.each do |solid|
    partNameCounter[solid.partName] = 0 unless partNameCounter.key?(solid.partName)
    next if partNameCounter[solid.partName] >= 15
    partNameCounter[solid.partName] += 1
    instance = Sketchup.active_model.entities.add_instance solid.definition, Geom::Transformation.new
    entityDisplayer.display instance
    totalCounter += 1
    # break if totalCounter >= 2
  end
  p partNameCounter

end

##____________________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__)) + '/'
  xmlfileListTest = [
                     'GeometryExtended.xml'
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
