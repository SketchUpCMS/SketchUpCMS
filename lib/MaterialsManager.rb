# Tai Sakuma <sakuma@fnal.gov>

require 'Material'

##____________________________________________________________________________||
class MaterialsManager
  attr_accessor :geometryManager
  attr_accessor :partsHash, :parts
  attr_accessor :defaultColor
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHash = Hash.new
    @parts = Array.new
  end
  def get(name)
    @partsHash.key?(name) ? @partsHash[name] : nil
  end
  def add part
    @parts << part
    @partsHash[part.name] = part 
  end
end

##____________________________________________________________________________||
