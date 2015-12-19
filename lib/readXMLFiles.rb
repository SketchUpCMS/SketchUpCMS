# Tai Sakuma <sakuma@fnal.gov>

require "rexml/document"
require "rexml/streamlistener"

##____________________________________________________________________________||
def readXMLFiles(xmlfileList, callBacks)
  xmlfileList.each do |file| 
    REXML::Document.parse_stream(File.new(file), callBacks)
  end
end

##____________________________________________________________________________||
