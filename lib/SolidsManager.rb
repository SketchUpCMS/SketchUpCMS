# Tai Sakuma <sakuma@fnal.gov>
require 'EntityDisplayer'
require 'Solid'

##____________________________________________________________________________||
class SolidsManager
  attr_accessor :geometryManager
  attr_accessor :eraseAfterDefine
  attr_accessor :partsHash, :parts
  attr_accessor :entityDisplayer

  KnownPartNames = [:PseudoTrap, :Trd1, :Polycone, :Polyhedra, :Trapezoid, :Tubs, :Box, :Cone, :Torus, :UnionSolid, :SubtractionSolid]

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
    if ! KnownPartNames.include?(part.partName)
      $stderr.write self.class.name + ": Unknown part name: \"#{part.partName}\"\n"
    end
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
