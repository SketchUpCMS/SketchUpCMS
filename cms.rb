# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

# $LOAD_PATH << '/usr/lib/ruby/1.8/'
$LOAD_PATH.push("/opt/local/lib/ruby/site_ruby/1.8", "/opt/local/lib/ruby/site_ruby/1.8/i686-darwin10", "/opt/local/lib/ruby/site_ruby", "/opt/local/lib/ruby/vendor_ruby/1.8", "/opt/local/lib/ruby/vendor_ruby/1.8/i686-darwin10", "/opt/local/lib/ruby/vendor_ruby", "/opt/local/lib/ruby/1.8", "/opt/local/lib/ruby/1.8/i686-darwin10")
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
load 'MaterialsManager.rb'

##____________________________________________________________________________||
def cmsmain

  read_xmlfiles
  draw_all_20111213_01

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
