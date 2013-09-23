#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require "rexml/document"
require "rexml/streamlistener"


##____________________________________________________________________________||
class DDLCallbacks
  include REXML::StreamListener
  attr_accessor :listenersDispatcher
  def tag_start(name, attributes)
    print "tag_start\n"
    print '  name = "', name, "\"\n"
    print '  attributes = ', attributes.inspect, "\n"
  end
  def text(text)
    print "text\n"
    print '  text = "', text, "\"\n"
  end
  def tag_end(name)
    print "tag_end\n"
    print '  name = "', name, "\"\n"
  end
end


##____________________________________________________________________________||
def main

  file = 'GeometryTOB.xml'
  callBacks = DDLCallbacks.new
  REXML::Document.parse_stream(File.new(file), callBacks)

end

##____________________________________________________________________________||

main
