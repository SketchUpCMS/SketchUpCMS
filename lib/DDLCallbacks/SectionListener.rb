# Tai Sakuma <sakuma@fnal.gov>

require "DDLCallbacks/DDLListener"

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
