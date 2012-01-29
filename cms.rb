# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

$LOAD_PATH << '/usr/lib/ruby/1.8/'
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

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
load 'AlgorithmManager.rb'

##____________________________________________________________________________||
def cmsmain

  read_xmlfiles
  draw_all_20111213_01

end

##____________________________________________________________________________||
def draw_all_20111213_01

  Sketchup.active_model.start_operation("Draw CMS", true)

  def drawChildren lp, depth = 1
    # return unless lp.isMaterialToHide(lp.materialName)
    # p "#{lp.name}, #{lp.materialName}"
    depth -= 1
    return if depth == -1
    lp.children.each do |pp|
      drawChildren(pp.child, depth)
      begin
        p pp unless pp.done
        pp.exec
      rescue Exception => e
        puts e.message
      end
    end
    return unless (lp.materialName.to_s =~ /Air$/ or lp.materialName.to_s =~ /free_space$/)
    if lp.children.size > 0
      lp.definition.entities.each do |e|
        next unless e.typename == 'ComponentInstance'
        next unless e.definition.name =~ /^solid_/
        e.erase!
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

  # lp = $logicalPartsManager.get("tracker:Tracker".to_sym)
  # drawChildren lp, 9
  # drawParentUntil lp, "tracker:Tracker".to_sym

  # lp = $logicalPartsManager.get("caloBase:CALO".to_sym)
  # drawChildren lp, 10

  # lp = $logicalPartsManager.get("muonBase:MUON".to_sym)
  # drawChildren lp, 6

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

  lp = $logicalPartsManager.get("cms:CMSE".to_sym)
  drawChildren lp, 13

  definition = lp.definition
  entities = Sketchup.active_model.entities
  transform = Geom::Transformation.new(Geom::Point3d.new(0, 0, 15.m))
  solidInstance = entities.add_instance definition, transform

  Sketchup.active_model.commit_operation
  Sketchup.active_model.active_view.zoom_extents
end

##____________________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__)) + '/'
  xmlfileListTest = [
        'fred_01.xml'
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
  $constantsManager = ConstantsManager.new
  $geometryManager = GeometryManager.new
  $solidsManager = SolidsManager.new
  $logicalPartsManager = LogicalPartsManager.new
  $posPartsManager = PosPartsManager.new
  $algorithmManager = AlgorithmManager.new

  geometryManager = $geometryManager
  geometryManager.materialsManager = $materialsManager
  geometryManager.rotationsManager = $rotationsManager
  geometryManager.constantsManager = $constantsManager
  geometryManager.solidsManager = $solidsManager
  geometryManager.logicalPartsManager = $logicalPartsManager
  geometryManager.posPartsManager = $posPartsManager
  geometryManager.algorithmManager = $algorithmManager

  $materialsManager.geometryManager = geometryManager
  $rotationsManager.geometryManager = geometryManager
  $constantsManager.geometryManager = geometryManager
  $solidsManager.geometryManager = geometryManager
  $logicalPartsManager.geometryManager = geometryManager
  $posPartsManager.geometryManager = geometryManager
  $algorithmManager.geometryManager = geometryManager

  geometryManager
end

##____________________________________________________________________________||
def buildDDLCallBacks(geometryManager)

  materialSectionListener = SectionWithPartListener.new("MaterialSection", geometryManager)
  rotationSectionListener = RotationSectionListener.new(geometryManager)
  constantsSectionListener = ConstantsSectionListener.new(geometryManager)
  solidSectionListener = SectionWithPartListener.new("SolidSection", geometryManager)
  logicalPartSectionListener = SectionWithPartListener.new("LogicalPartSection", geometryManager)
  posPartSectionListener = SectionWithPartListener.new("PosPartSection", geometryManager)
  algorithmListener = AlgorithmListener.new(geometryManager)

  mainListenersDispatcher = HashListenersDispatcher.new
  mainListenersDispatcher.add_listner('MaterialSection', materialSectionListener)
  mainListenersDispatcher.add_listner('RotationSection', rotationSectionListener)
  mainListenersDispatcher.add_listner('ConstantsSection', constantsSectionListener)
  mainListenersDispatcher.add_listner('SolidSection', solidSectionListener)
  mainListenersDispatcher.add_listner('LogicalPartSection', logicalPartSectionListener)
  mainListenersDispatcher.add_listner('PosPartSection', posPartSectionListener)
  mainListenersDispatcher.add_listner('Algorithm', algorithmListener)

  callBacks = DDLCallbacks.new
  callBacks.listenersDispatcher = mainListenersDispatcher
  callBacks
end

##____________________________________________________________________________||

cmsmain
