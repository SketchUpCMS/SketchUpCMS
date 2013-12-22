# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

require File.dirname(__FILE__) + '/../../sitecfg.rb'

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

  draw_gratr_20120317_02

end

##____________________________________________________________________________||
def draw_gratr_20120317_02
  def create_array_to_draw graph, topName


    # GRATR::Digraph
    graphFromCMSE = subgraph_from(graph, topName)

    nameDepthEB = [ {:name => :"eregalgo:EFAW", :depth => 0},
                    {:name => :"eregalgo:EBCOOL1", :depth => 0},
                    {:name => :"eregalgo:EBCOOL2", :depth => 0},
                    {:name => :"eregalgo:EBCOOL3", :depth => 0},
                    {:name => :"eregalgo:EBCOOL4", :depth => 0},
                     ]

    nameDepthEE = [ {:name => :"eregalgo:EESCEnv1", :depth => 0},
                    {:name => :"eregalgo:EESCEnv2", :depth => 0},
                    {:name => :"eregalgo:EESCEnv3", :depth => 0},
                    {:name => :"eregalgo:EESCEnv4", :depth => 0},
                    {:name => :"eregalgo:EESCEnv5", :depth => 0},
                    {:name => :"eregalgo:EESCEnv6", :depth => 0},
                    {:name => :"eefixed:EEBackPlate", :depth => 0},
                    {:name => :"eefixed:EERMCP", :depth => 0},
                    {:name => :"eefixed:EESRing", :depth => 0},
                    {:name => :"esalgo:SFLX0a", :depth => 0},
                    {:name => :"esalgo:SFLX0b", :depth => 0},
                    {:name => :"esalgo:SFLX0c", :depth => 0},
                    {:name => :"esalgo:SFLX1a", :depth => 0},
                    {:name => :"esalgo:SFLX1b", :depth => 0},
                    {:name => :"esalgo:SFLX1c", :depth => 0},
                    {:name => :"esalgo:SFLX1d", :depth => 0},
                    {:name => :"esalgo:SFLX1e", :depth => 0},
                    {:name => :"esalgo:SFLX2a", :depth => 0},
                    {:name => :"esalgo:SFLX2b", :depth => 0},
                    {:name => :"esalgo:SFLX3a", :depth => 0},
                    {:name => :"esalgo:SFLX3b", :depth => 0},
                    {:name => :"esalgo:SFLY0a", :depth => 0},
                    {:name => :"esalgo:SFLY0b", :depth => 0},
                    {:name => :"esalgo:SFLY0c", :depth => 0},
                    {:name => :"esalgo:SFLY1a", :depth => 0},
                    {:name => :"esalgo:SFLY1b", :depth => 0},
                    {:name => :"esalgo:SFLY1c", :depth => 0},
                    {:name => :"esalgo:SFLY1d", :depth => 0},
                    {:name => :"esalgo:SFLY1e", :depth => 0},
                    {:name => :"esalgo:SFLY2a", :depth => 0},
                    {:name => :"esalgo:SFLY2b", :depth => 0},
                    {:name => :"esalgo:SFLY3a", :depth => 0},
                    {:name => :"esalgo:SFLY3b", :depth => 0},
                    {:name => :"esalgo:SFID", :depth => 0},
                    {:name => :"esalgo:SFOD", :depth => 0},
                    {:name => :"eefixed:ESCone", :depth => 0},
                  ]



    nameDepthHB = [
                   {:name => :"hcalbarrelalgo:HBModule", :depth => 1},
                  ]

    nameDepthHE = [ 
                    {:name => :"hcalendcapalgo:HEModule", :depth => 2},
                  ]


    nameDepthMGNT = [
                     {:name => :"mgnt:MGNT", :depth => 0},
                    ]


    nameDepthECAL = nameDepthEB + nameDepthEE
    nameDepthHCAL = nameDepthHB + nameDepthHE
    nameDepthMUON = nameDepthMGNT

    nameDepthBEAM = [ {:name => :"beampipe:BEAM", :depth => 1},
                      {:name => :"beampipe:BEAM1", :depth => 1},
                    ]

    nameDepthList = nameDepthBEAM + nameDepthMUON + nameDepthHCAL + nameDepthECAL

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
  draw_array graphAll, arrayToDraw.reverse, topName
end

##____________________________________________________________________________||
def draw_array graph, arrayToDraw, topName

  Sketchup.active_model.definitions.purge_unused
  start_time = Time.now
  Sketchup.active_model.start_operation("Draw CMS", true)

  arrayToDraw.each do |parent|
    children = graph.neighborhood(parent, :out)
    children = children.select { |e| arrayToDraw.include?(e) }
    children.each do |child|
      posParts = $posPartsManager.getByParentChild(parent, child)
      posParts.each do |posPart|
        # puts "  exec posPart #{posPart.parentName} - #{posPart.childName}"
        posPart.exec
      end
    end
  end

  arrayToDraw.each do |v|
    logicalPart = $logicalPartsManager.get(v)
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /Air$/
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /free_space$/
    logicalPart.placeSolid()
  end

  $logicalPartsManager.get(topName).placeSolid()

  arrayToDraw.each do |v|
    logicalPart = $logicalPartsManager.get(v)
    logicalPart.define()
  end

  lp = $logicalPartsManager.get(topName.to_sym)
  definition = lp.definition
  if definition
    entities = Sketchup.active_model.entities
    transform = Geom::Transformation.new(Geom::Point3d.new(0, 0, 15.m))
    solidInstance = entities.add_instance definition, transform
  end

  Sketchup.active_model.commit_operation
  end_time = Time.now
  puts "Time elapsed #{(end_time - start_time)*1000} milliseconds"


end

##____________________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__)) + '/../../'
  xmlfileListTest = [
                     'GeometryExtended.xml'
                    ]

  xmlfileList = xmlfileListTest

  xmlfileList.map! {|f| f = topDir + f }

  p xmlfileList

  geometryManager = buildGeometryManager()
  callBacks = buildDDLCallBacks(geometryManager)
  readXMLFiles(xmlfileList, callBacks, geometryManager)
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
