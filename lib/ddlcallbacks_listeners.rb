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
class SectionListener < DDLListener
  def initialize(sectionaName, geometryManager)
    super()
    @geometryManager = geometryManager
    @sectionaName = sectionaName.to_sym
  end
  def listener_enter(name, attributes)
    @sectionLabel = attributes['label'].sub(/\.xml/, '')
  end
  def listener_exit(name)
    @sectionLabel = ''
  end
  def tag_start(name, attributes)
    @name = name
    @attributes = attributes
  end
  def tag_end(name)
    @geometryManager.add_entry(@sectionaName, @sectionLabel, @name, @attributes)
  end
end

##____________________________________________________________________________||
require "SectionWithPartListener"
