# Tai Sakuma <sakuma@fnal.gov>
require 'EntityDisplayer'
require 'Solid'

##____________________________________________________________________________||
class SolidsManager
  attr_accessor :geometryManager
  attr_accessor :eraseAfterDefine
  attr_accessor :partsHash, :parts
  attr_accessor :entityDisplayer
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHash = Hash.new
    @parts = Array.new
    @eraseAfterDefine = true
  end
  def clear
    @entityDisplayer.clear
    @parts.each {|p| p.clear if p}
  end
  def get(name)
    @partsHash.key?(name)? @partsHash[name] : nil
  end
  def add part
    @parts << part
    @partsHash[part.name] = part 
  end

  def moveInstanceAway(instance)
    @entityDisplayer.display instance unless @eraseAfterDefine
    instance.erase! if @eraseAfterDefine
    instance
  end


end

##____________________________________________________________________________||
