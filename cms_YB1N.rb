# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

require File.dirname(__FILE__) + '/sitecfg.rb'

require 'gratr'

require 'buildGeometryManager'
require 'buildDDLCallBacks'
require 'readXMLFiles'
require 'PartBuilder'
require 'solids'
require 'graph_functions.rb'
load 'PosPartExecuter.rb'

##__________________________________________________________________||
def cmsmain

  read_xmlfiles
  # read_xmlfiles_from_cache

  draw_gratr

end

##__________________________________________________________________||
def draw_gratr
  def create_graphToDraw graph, topName

    nameDepthMB = [
                   {:name => :"muonBase:MBWheel_1N", :depth => 2},
                  ]

    nameDepthList = nameDepthMB

    names = nameDepthList.collect { |e| e[:name] }
    graphTopToNames = subgraph_from_to(graph, topName, names)

    graphNamesToDepths = graph.class.new
    nameDepthList.each do |e|
      graphNamesToDepths = graphNamesToDepths + subgraph_from_depth(graph, e[:name], e[:depth])
    end

    graphToDraw = graphTopToNames + graphNamesToDepths

    graphToDraw
  end

  # all PosParts in the XML file
  graphAll = GRATR::DirectedPseudoGraph.new
  $posPartsManager.parts.each { |pp| graphAll.add_edge!(pp.parentName, pp.childName, pp) }

  topName = :"cms:CMSE"
  graphToDraw = create_graphToDraw graphAll, topName

  # e.g. [:"cms:CMSE", :"tracker:Tracker", :"tob:TOB", .. ]
  arrayToDraw = graphToDraw.size > 0 ? graphToDraw.topsort(topName) : [topName]

  draw_array graphToDraw, topName
end

##__________________________________________________________________||
def draw_array graph, topName

  Sketchup.active_model.definitions.purge_unused
  start_time = Time.now
  Sketchup.active_model.start_operation("Draw CMS", true)

  posPartExecuter =  PosPartExecuter.new $geometryManager

  graph.edges.each do |edge|
    posPart = edge.label
    posPartExecuter.exec posPart
  end

  graph.topsort.reverse.each do |v|
    logicalPart = $logicalPartsManager.get(v)
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /Air$/
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /free_space$/
    logicalPart.placeSolid()
  end

  # $logicalPartsManager.get(topName).placeSolid()

  graph.topsort.reverse.each do |v|
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

##__________________________________________________________________||
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

##__________________________________________________________________||
def read_xmlfiles_from_cache
  fillGeometryManager($geometryManager)
  $geometryManager.reload_from_cache
end

##__________________________________________________________________||

cmsmain
