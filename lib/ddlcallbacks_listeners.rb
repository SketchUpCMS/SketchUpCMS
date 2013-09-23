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
require "SectionListener"
require "SectionWithPartListener"
