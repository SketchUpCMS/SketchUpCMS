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
require 'graph_functions_DD'
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

  vertices = Hash[$logicalPartsManager.parts.map { |p| [p.name, LogicalPartInstance.new($geometryManager, p)] } ]

  topName = :"cms:CMSE"

  subNames = [:"ebalgo:ESPM"]

  nameDepthList = [
    {:name => :"eregalgo:EFAW", :depth => 10},
    {:name => :"eregalgo:EBCOOL1", :depth => 2},
    {:name => :"eregalgo:EBCOOL2", :depth => 2},
    {:name => :"eregalgo:EBCOOL3", :depth => 2},
    {:name => :"eregalgo:EBCOOL4", :depth => 2},
  ]

  graphTopToSub = subgraph_from_to(graphAll, topName, subNames)

  names = nameDepthList.collect { |e| e[:name] }
  graphSubToNames = subgraph_from_to(graphAll, subNames, names)

  graphNamesToDepths = graphAll.class.new
  nameDepthList.each do |e|
    graphNamesToDepths = graphNamesToDepths + subgraph_from_depth(graphAll, e[:name], e[:depth])
  end

  graph = graphTopToSub + graphSubToNames + graphNamesToDepths

  edges = graph.adjacent(:"ebalgo:ESPM", {:direction => :in, :type => :edges})

  edges[0, 5].each do |e|
    graph.remove_edge! e
  end

  edges[17, 1].each do |e|
    graph.remove_edge! e
  end

  edges[18, 18].each do |e|
    graph.remove_edge! e
  end

  make_logicalPart_unique(graph, edges[5, 3], vertices, true)
  graph = subgraph_trim_depth graph, :"ebalgo:ESPM#1", 4

  make_logicalPart_unique(graph, edges[8, 3], vertices, true)
  graph = subgraph_trim_depth graph, :"ebalgo:ESPM#2", 3

  make_logicalPart_unique(graph, edges[11, 3], vertices, true)
  graph = subgraph_trim_depth graph, :"ebalgo:ESPM#3", 2

  graph = subgraph_trim_depth graph, :"ebalgo:ESPM", 1

  graph = subgraph_from(graph, topName)

  n_instances = n_paths(graph, topName)

  graph.topsort.each do |v|
    puts " %-30s %10d   %s" % [v, n_instances[v], vertices[v].inspect]
  end

  draw_array graph, vertices, topName
end

##__________________________________________________________________||
def draw_array graph, vertexLabel, topName

  Sketchup.active_model.definitions.purge_unused
  start_time = Time.now
  Sketchup.active_model.start_operation("Draw CMS", true)

  posPartExecuter = PosPartExecuter.new $geometryManager


  graph.edges.each do |edge|
    posPart = edge.label
    posPartExecuter.exec posPart, vertexLabel[edge.source], vertexLabel[edge.target]
  end

  graph.topsort.reverse.each do |v|
    logicalPart = vertexLabel[v]
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /Air$/
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /free_space$/
    logicalPart.placeSolid()
  end

  # $logicalPartsManager.get(topName).placeSolid()

  graph.topsort.reverse.each do |v|
    logicalPart = vertexLabel[v]
    logicalPart.define()
  end

  lp = vertexLabel[topName.to_sym]
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
    'GeometryExtended.xml'
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
