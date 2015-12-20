# Tai Sakuma <sakuma@fnal.gov>

require 'GeometryManager'
require 'RotationsManager.rb'
require 'SolidsManager.rb'
require 'LogicalPartsManager.rb'
require 'PosPartsManager.rb'
require 'MaterialsManager.rb'

##__________________________________________________________________||
def fillGeometryManager(geometryManager)

  $materialsManager = MaterialsManager.new
  $rotationsManager = RotationsManager.new
  $solidsManager = SolidsManager.new
  $logicalPartsManager = LogicalPartsManager.new
  $posPartsManager = PosPartsManager.new

  geometryManager.partBuilder = PartBuilder.new

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

##__________________________________________________________________||
def buildGeometryManager
  $geometryManager = GeometryManager.new
  fillGeometryManager($geometryManager)
  $geometryManager
end

##__________________________________________________________________||
