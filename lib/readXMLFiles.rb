# Tai Sakuma <sakuma@fnal.gov>

require "rexml/document"
require "rexml/streamlistener"

##____________________________________________________________________________||
def readXMLFiles(xmlfileList, callBacks, geometryManager)
  xmlfileList.each do |file| 
    geometryManager.xmlFilePath = file
    REXML::Document.parse_stream(File.new(file), callBacks)
  end
end

##____________________________________________________________________________||
