# Tai Sakuma <sakuma@fnal.gov>
require 'LogicalPart'

##____________________________________________________________________________||
class LogicalPartsManager
  attr_accessor :geometryManager
  attr_accessor :partsHash, :parts

  KnownPartNames = [:LogicalPart]

  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHash = Hash.new
    @parts = Array.new
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
