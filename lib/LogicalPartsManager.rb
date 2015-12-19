# Tai Sakuma <sakuma@fnal.gov>
require 'EntityDisplayer'
require 'LogicalPart'

##____________________________________________________________________________||
class LogicalPartsManager
  attr_accessor :geometryManager
  attr_accessor :eraseAfterDefine
  attr_accessor :partsHash, :parts
  attr_accessor :entityDisplayer

  KnownPartNames = [:LogicalPart]

  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHash = Hash.new
    @parts = Array.new
    @eraseAfterDefine = true
  end
  def get(name)
    @partsHash.key?(name)? @partsHash[name] : nil
  end
  def add part
    raise StandardError, "unknown part name \"#{partName}\"" unless KnownPartNames.include?(part.partName)
    @parts << part
    @partsHash[part.name] = part 
  end

end

##____________________________________________________________________________||
