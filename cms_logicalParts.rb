# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

require File.dirname(__FILE__) + '/sitecfg.rb'

require 'gratr'

require 'buildDDLCallBacks'
require 'readXMLFiles'
require 'PartBuilder'
require 'solids'
require 'GeometryManager'
require 'EntityDisplayer.rb'
require 'RotationsManager.rb'
require 'SolidsManager.rb'
require 'LogicalPartsManager.rb'
require 'PosPartsManager.rb'
require 'MaterialsManager.rb'
require 'defs.rb'

##____________________________________________________________________________||
def cmsmain


  read_xmlfiles
  # read_xmlfiles_from_cache


  draw_solids

end

##____________________________________________________________________________||
def draw_solids

  entityDisplayer = EntityDisplayer.new('logicalParts', -100.m, 0, 0)

  totalCounter = 0

  $logicalPartsManager.parts.each do |lg|
    lg.placeSolid
    instance = Sketchup.active_model.entities.add_instance lg.define, Geom::Transformation.new
    entityDisplayer.display instance
    totalCounter += 1
    break if totalCounter >= 10
  end

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
def fillGeometryManager(geometryManager)

  $materialsManager = MaterialsManager.new
  $rotationsManager = RotationsManager.new
  $solidsManager = SolidsManager.new
  $logicalPartsManager = LogicalPartsManager.new
  $posPartsManager = PosPartsManager.new

  geometryManager.partBuilder = PartBuilder.new

  $solidsManager.entityDisplayer = EntityDisplayer.new('solids', 100.m, 0, 0)
  $logicalPartsManager.entityDisplayer = EntityDisplayer.new('logicalParts', -100.m, 0, 0)

  geometryManager = geometryManager
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
def buildGeometryManager
  $geometryManager = GeometryManager.new
  fillGeometryManager($geometryManager)
  $geometryManager
end

##____________________________________________________________________________||

cmsmain
