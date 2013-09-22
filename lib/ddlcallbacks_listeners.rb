# Tai Sakuma <sakuma@fnal.gov>

require "DDLCallbacks"
require "HashListenersDispatcher"

##____________________________________________________________________________||
class DDLListener
  def tag_start(name, attributes) end
  def tag_end(name) end
  def text(text) end
  def listener_enter(name, attributes) end
  def listener_exit(name) end
end

##____________________________________________________________________________||
class NullListener < DDLListener
  def tag_start(name, attributes) end
  def tag_end(name) end
  def text(text) end
  def listener_enter(name, attributes) end
  def listener_exit(name) end
end

##____________________________________________________________________________||
class RotationSectionListener < DDLListener
  def initialize(geometryManager)
    super()
    @geometryManager = geometryManager
  end
  def listener_enter(name, attributes)
    @sectionLabel = attributes['label'].sub(/\.xml/, '')
  end
  def listener_exit(name)
    @sectionLabel = ''
  end
  def tag_start(name, attributes)
    @geometryManager.add_entry(:RotationSection, @sectionLabel, name, attributes)
  end
end

##____________________________________________________________________________||
require "SectionWithPartListener"
