#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)) + "/lib")
require 'buildDDLCallBacks'
require 'readXMLFiles'

##____________________________________________________________________________||
class GeometryManagerDump
  def add_entry sectionName, sectionLabel, partName, args
    print "add_entry\n"
    p sectionName, sectionLabel, partName, args
    print "\n"
  end
end


##____________________________________________________________________________||
def main

  topDir = File.expand_path(File.dirname(__FILE__)) + '/'
  xmlfileList = ['GeometryTOB.xml']
  xmlfileList.map! {|f| f = topDir + f }

  geometryManager = GeometryManagerDump.new
  callBacks = buildDDLCallBacks(geometryManager)
  readXMLFiles(xmlfileList, callBacks)

end

##____________________________________________________________________________||

main
