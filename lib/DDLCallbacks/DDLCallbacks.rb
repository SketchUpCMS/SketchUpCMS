# Tai Sakuma <sakuma@fnal.gov>
require "rexml/document"
require "rexml/streamlistener"

##____________________________________________________________________________||
class ListenerDispatcher
  def tag_start(name, attributes) end
  def text(text) end
  def tag_end(name) end
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
