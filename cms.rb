# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

# $LOAD_PATH << '/usr/lib/ruby/1.8/'
$LOAD_PATH.push("/opt/local/lib/ruby/site_ruby/1.8", "/opt/local/lib/ruby/site_ruby/1.8/i686-darwin10", "/opt/local/lib/ruby/site_ruby", "/opt/local/lib/ruby/vendor_ruby/1.8", "/opt/local/lib/ruby/vendor_ruby/1.8/i686-darwin10", "/opt/local/lib/ruby/vendor_ruby", "/opt/local/lib/ruby/1.8", "/opt/local/lib/ruby/1.8/i686-darwin10")
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'gratr'

require 'ddlcallbacks'
load 'ddlcallbacks.rb'

# require 'solids'
load 'solids.rb'

require 'GeometryManager'

load 'GeometryManager.rb'
load 'EntityDisplayer.rb'
load 'RotationsManager.rb'
load 'SolidsManager.rb'
load 'LogicalPartsManager.rb'
load 'PosPartsManager.rb'
load 'MaterialsManager.rb'

load 'defs.rb'

##____________________________________________________________________________||
def cmsmain

  read_xmlfiles
  draw_gratr_20120317_02
  # draw_all_20111213_01

end

##____________________________________________________________________________||
def draw_gratr_20120317_02
  def create_array_to_draw graph

    # GRATR::Digraph
    graphFromCMSE = subgraph_from(graph, :"cms:CMSE")

    name = :"tob:TOB"
    # name = :"muonBase:MBWheel_0"
    # name = :"mb4:MB4FeetN"

    # Array (e.g. [:"muonBase:MBWheel_0", :"muonBase:MB", :"muonBase:MUON", :"cms:CMSE"])
    topSortFromCMSEToName = topsort_from_to(graphFromCMSE, :"cms:CMSE", name)

    # Array (e.g. [:"muonBase:MBWheel_0", :"muonYoke:YB2_w0_t4", .. ])
    topSortFromName = topsort_from_depth(graphFromCMSE, name, 3)

    # Array (e.g. [:"mb1:MB1RPC_OP", ... , :"muonBase:MUON", :"cms:CMSE"])
    toDrawNames = topSortFromCMSEToName[0..-2] + topSortFromName

    toDrawNames
  end

  # all PosParts in the XML file
  graphAll = GRATR::Digraph.new
  $posPartsManager.parts.each { |pp| graphAll.add_edge!(pp.parentName, pp.childName) }

  arrayToDraw = create_array_to_draw graphAll
  draw_array graphAll, arrayToDraw.reverse
end

##____________________________________________________________________________||
def draw_array graph, arrayToDraw

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

  arrayToDraw.each do |v|
    logicalPart = $logicalPartsManager.get(v)
    logicalPart.define()
  end

  # lp = $logicalPartsManager.get("cms:CMSE".to_sym)
  lp = $logicalPartsManager.get("tob:TOB".to_sym)
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
def draw_all_20111213_01

  $solidsManager.clear
  $logicalPartsManager.clear
  $posPartsManager.clear
  Sketchup.active_model.definitions.purge_unused

  $solidsManager.eraseAfterDefine = true
  $logicalPartsManager.eraseAfterDefine = true

  start_time = Time.now
  Sketchup.active_model.start_operation("Draw CMS", true)

  def drawChildren lp, depth = 1
    # return unless lp.isMaterialToHide(lp.materialName)
    # p "#{lp.name}, #{lp.materialName}"
    depth -= 1
    return if depth == -1
    lp.children.each do |pp|
      drawChildren(pp.child, depth)
      next if pp.done
      begin
        ## p pp 
        if depth == 0 or pp.child.children.size == 0 or not (pp.child.materialName.to_s =~ /Air$/ or pp.child.materialName.to_s =~ /free_space$/)
          pp.child.instantiateSolid()
        end
        pp.exec
      rescue Exception => e
        puts e.message
      end
    end
  end

  def drawParentUntil lp, pname
    return if lp.name == pname
    lp.parents.each do |pp|
      drawParentUntil pp.parent, pname
      begin
        p pp unless pp.done
        pp.exec
      rescue Exception => e
        puts e.message
      end
    end
  end

  
  lp = $logicalPartsManager.get("muonBase:MBWheel_0".to_sym)
  drawChildren lp, 9

  # lp = $logicalPartsManager.get("tracker:Tracker".to_sym)
  # drawChildren lp, 9
  # drawParentUntil lp, "tracker:Tracker".to_sym

  # lp = $logicalPartsManager.get("caloBase:CALO".to_sym)
  # drawChildren lp, 10

  # lp = $logicalPartsManager.get("muonBase:MUON".to_sym)
  # drawChildren lp, 9

  # lp = $logicalPartsManager.get("hcalforwardalgo:VCAL".to_sym)
  # drawChildren lp, 4

  # lp = $logicalPartsManager.get("forward:TotemT1".to_sym)
  # drawChildren lp, 3
  # drawParentUntil lp, "cms:CMSE".to_sym
  # 
  # lp = $logicalPartsManager.get("forward:TotemT2".to_sym)
  # drawChildren lp, 3
  # drawParentUntil lp, "cms:CMSE".to_sym

  # lp = $logicalPartsManager.get("beampipe:BEAM".to_sym)
  # drawChildren lp, 5
  # drawParentUntil lp, "cms:CMSE".to_sym
  # lp = $logicalPartsManager.get("beampipe:BEAM1".to_sym)
  # drawChildren lp, 5
  # drawParentUntil lp, "cms:CMSE".to_sym
  # lp = $logicalPartsManager.get("beampipe:BEAM2".to_sym)
  # drawChildren lp, 5
  # drawParentUntil lp, "cms:CMSE".to_sym
  # lp = $logicalPartsManager.get("beampipe:BEAM3".to_sym)
  # drawChildren lp, 5
  # drawParentUntil lp, "cms:CMSE".to_sym

  # lp = $logicalPartsManager.get("cms:CMSE".to_sym)
  # drawChildren lp, 13

  definition = lp.definition
  if definition
    entities = Sketchup.active_model.entities
    transform = Geom::Transformation.new(Geom::Point3d.new(0, 0, 15.m))
    solidInstance = entities.add_instance definition, transform
  end

  Sketchup.active_model.commit_operation
  end_time = Time.now
  puts "Time elapsed #{(end_time - start_time)*1000} milliseconds"

  Sketchup.active_model.active_view.zoom_extents
end

##____________________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__)) + '/'
  xmlfileListTest = [
        # 'fred_01.xml'
        'tob_03.xml'
                    ]

  xmlfileList = xmlfileListTest

  xmlfileList.map! {|f| f = topDir + f }

  p xmlfileList

  geometryManager = buildGeometryManager()
  callBacks = buildDDLCallBacks(geometryManager)
  readXMLFiles(xmlfileList, callBacks, geometryManager)
end

##____________________________________________________________________________||
def buildGeometryManager
  $materialsManager = MaterialsManager.new
  $rotationsManager = RotationsManager.new
  $geometryManager = GeometryManager.new
  $solidsManager = SolidsManager.new
  $logicalPartsManager = LogicalPartsManager.new
  $posPartsManager = PosPartsManager.new

  $solidsManager.entityDisplayer = EntityDisplayer.new('solids', 100.m, 0, 0)
  $logicalPartsManager.entityDisplayer = EntityDisplayer.new('logicalParts', -100.m, 0, 0)

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
