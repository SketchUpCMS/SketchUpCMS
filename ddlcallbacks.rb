# Tai Sakuma <sakuma@fnal.gov>
require "rexml/document"
require "rexml/streamlistener"

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
class ListenerDispatcher
  def tag_start(name, attributes) end
  def text(text) end
  def tag_end(name) end
end

##____________________________________________________________________________||
class HashListenersDispatcher < ListenerDispatcher
  def initialize()
    @currentListener = nil
    @currentTagName = nil
    @nullListener = NullListener.new
    @listenersHash = Hash.new
    @unknownTags = Array.new
  end
  def add_listner(name, listener)
    @listenersHash[name] = listener
  end

  def tag_start(name, attributes)
    if @currentTagName
      @currentListener.tag_start(name, attributes)
      return
    end
    @currentTagName = name
    @currentListener = @listenersHash.key?(name) ? @listenersHash[name] : @nullListener
    @currentListener.listener_enter(name, attributes)

    if not (@listenersHash.key?(name) or @unknownTags.include?(name))
      @unknownTags << name
      print "unknown tag: #{name}\n"
    end
  end
  def text(text)
    if @currentTagName
      @currentListener.text(text)
      return
    end
  end
  def tag_end(name)
    if @currentTagName == name
      @currentListener.listener_exit(name)
      @currentTagName = nil
      @currentListener = nil
    else
      @currentListener.tag_end(name)
    end
  end
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
    @sectionaName = sectionaName
  end
  def listener_enter(name, attributes, sectionLabel)
    @sectionLabel = sectionLabel
    @partName = name
    @args = attributes
  end
  def listener_exit(name)
    super
    @geometryManager.add_geometry(@sectionaName, @sectionLabel, @partName, @args)
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
    @geometryManager.add_rotation('RotationSection', @sectionLabel, name, attributes)
  end
end

##____________________________________________________________________________||
class ConstantsSectionListener < DDLListener
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
    if name == 'Constant'
      @geometryManager.add_constant('ConstantsSection', @sectionLabel, name, attributes)
    end
  end
end

##____________________________________________________________________________||
class DDLCallbacks
  include REXML::StreamListener
  attr_accessor :listenersDispatcher
  def tag_start(name, attributes)
    return if name == "DDDefinition"
    @listenersDispatcher.tag_start name, attributes
  end
  def text(text)
    @listenersDispatcher.text text
  end
  def tag_end(name)
    return if name == "DDDefinition"
    @listenersDispatcher.tag_end name
  end
end

##____________________________________________________________________________||
