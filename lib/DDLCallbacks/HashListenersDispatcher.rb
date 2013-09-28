# Tai Sakuma <sakuma@fnal.gov>

require "DDLCallbacks/ListenerDispatcher"
require "DDLCallbacks/NullListener"

##____________________________________________________________________________||
class HashListenersDispatcher < ListenerDispatcher
  attr_reader :currentListener, :currentTagName

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
      $stderr.write self.class.name + ": Unknown tag: \"#{name}\"\n"
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
