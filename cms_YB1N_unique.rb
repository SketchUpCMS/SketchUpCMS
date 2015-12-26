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
load 'LogicalPartInstance.rb'
load 'LogicalPartDefiner.rb'

##__________________________________________________________________||
def cmsmain

  read_xmlfiles
  # read_xmlfiles_from_cache

  draw_gratr

end

##__________________________________________________________________||
def draw_gratr

  # all PosParts in the XML file
  graphAll = GRATR::DirectedPseudoGraph.new
  $posPartsManager.parts.each { |pp| graphAll.add_edge!(pp.parentName, pp.childName, pp) }

  topName = :"cms:CMSE"

  subName = :"muonBase:MBWheel_1N"

  nameDepthList = [
    {:name => :"mb1:MB1ChimHoneycombBox", :depth => 0},
    {:name => :"mb1:MB1ChimSuperLayerZ", :depth => 0},
    {:name => :"mb1:MB1ChimSuperLayerPhi", :depth => 0},
    {:name => :"mb1:MB1HoneycombBox", :depth => 0},

    # :"mb1:MB1SuperLayerZ"
    {:name => :"mb1:MB1SLZLayer_56Cells", :depth => 0},
    {:name => :"mb1:MB1SLZLayer_58Cells", :depth => 0},
    {:name => :"mb1:MB1SLZLayer_57Cells", :depth => 0},
    {:name => :"mb1:MB1SLZAlPlateInner", :depth => 0},
    {:name => :"mb1:MB1SLZAlPlateOuter", :depth => 0},

    # :"mb1:MB1SuperLayerPhi"
    {:name => :"mb1:MB1SLPhiLayer_48Cells", :depth => 0},
    {:name => :"mb1:MB1SLPhiLayer_50Cells", :depth => 0},
    {:name => :"mb1:MB1SLPhiLayer_49Cells", :depth => 0},
    {:name => :"mb1:MB1SLPhiAlPlateInner", :depth => 0},
    {:name => :"mb1:MB1SLPhiAlPlateOuter", :depth => 0},
  ]

  graphTopToSub = subgraph_from_to(graphAll, topName, [subName])

  names = nameDepthList.collect { |e| e[:name] }
  graphSubToNames = subgraph_from_to(graphAll, subName, names)

  graphNamesToDepths = graphAll.class.new
  nameDepthList.each do |e|
    graphNamesToDepths = graphNamesToDepths + subgraph_from_depth(graphAll, e[:name], e[:depth])
  end

  graph = graphTopToSub + graphSubToNames + graphNamesToDepths

  draw_array graph, topName
end

##__________________________________________________________________||
def draw_array graph, topName

  Sketchup.active_model.definitions.purge_unused
  start_time = Time.now
  Sketchup.active_model.start_operation("Draw CMS", true)

  posPartExecuter = PosPartExecuter.new $geometryManager

  logicalPartInstances = { }

  graph.topsort.each do |v|
    logicalPart = $logicalPartsManager.get(v)
    puts "logicalPart not found: #{v}" unless logicalPart
    logicalPartInstances[v] = LogicalPartInstance.new $geometryManager, logicalPart
    # logicalPartInstances[v] = logicalPart
  end

  graph.edges.each do |edge|
    posPart = edge.label
    posPartExecuter.exec posPart, logicalPartInstances[edge.source], logicalPartInstances[edge.target]
  end

  graph.topsort.reverse.each do |v|
    logicalPart = logicalPartInstances[v]
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /Air$/
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /free_space$/
    logicalPart.placeSolid()
  end

  # $logicalPartsManager.get(topName).placeSolid()

  graph.topsort.reverse.each do |v|
    logicalPart = logicalPartInstances[v]
    logicalPart.define()
  end

  lp = logicalPartInstances[topName.to_sym]
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
    # 'GeometryExtended.xml'
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
