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
class PartListenerDispatcher < ListenerDispatcher
  attr_accessor :listener
  def initialize()
    @isInListen = false
    @currentTagName = ""
  end
  def tag_start(name, attributes, sectionLabel)
    if (@isInListen)
      @listener.tag_start(name, attributes)
      return
    end
    @currentTagName = name
    @isInListen = true
    @listener.listener_enter(name, attributes, sectionLabel)
  end

  def tag_end(name)
    if (@isInListen)
      if (@currentTagName == name)
        @listener.listener_exit(name)
        @isInListen = false
        @currentTagName = ""
        return
      else
        @listener.tag_end(name)
        return
      end
    end
  end
end

##____________________________________________________________________________||
class PartListener < DDLListener
  def initialize(geometryManager, sectionaName)
    super()
    @geometryManager = geometryManager
    @sectionaName = sectionaName.to_sym
  end
  def listener_enter(name, attributes, sectionLabel)
    @sectionLabel = sectionLabel
    @partName = name
    @args = attributes
  end
  def listener_exit(name)
    super
    @geometryManager.add_entry(@sectionaName, @sectionLabel, @partName, @args)
  end
  def tag_start(name, attributes)
    @args[name] = Array.new if !(@args.key?(name))
    @args[name] << attributes
  end
end

##____________________________________________________________________________||
class SectionWithPartListener < DDLListener
  def initialize(sectionaName, geometryManager)
    super()
    @listenersDispatcher = PartListenerDispatcher.new
    @listenersDispatcher.listener = PartListener.new(geometryManager, sectionaName)
  end
  def listener_enter(name, attributes)
    @sectionLabel = attributes['label'].sub(/\.xml/, '')
  end
  def listener_exit(name)
    @sectionLabel = ''
  end
  def tag_start(name, attributes)
    @listenersDispatcher.tag_start name, attributes, @sectionLabel
  end
  def tag_end(name)
    @listenersDispatcher.tag_end name
  end
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
