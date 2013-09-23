# Tai Sakuma <sakuma@fnal.gov>

require "DDLCallbacks/SectionListener"
require "DDLCallbacks/SectionWithPartListener"
require "DDLCallbacks/HashListenersDispatcher"
require "DDLCallbacks/DDLCallbacks"

##____________________________________________________________________________||
def buildDDLCallBacks(geometryManager)

  materialSectionListener = SectionWithPartListener.new("MaterialSection", geometryManager)
  rotationSectionListener = SectionListener.new("RotationSection", geometryManager)
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
