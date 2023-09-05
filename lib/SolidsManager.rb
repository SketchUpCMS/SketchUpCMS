# Tai Sakuma <sakuma@fnal.gov>
# Thomas McCauley <thomas.mccauley@cern.ch>
require 'Solid'

##__________________________________________________________________||
class SolidsManager
  attr_accessor :geometryManager
  attr_accessor :partsHash, :parts

  KnownPartNames = [:PseudoTrap, :Trd1, :Polycone, :Polyhedra, :Trapezoid, :Tubs, :Box, :Cone, :Torus, :UnionSolid, :SubtractionSolid, :ExtrudedPolygon]

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
    if ! KnownPartNames.include?(part.partName)
      $stderr.write self.class.name + ": Unknown part name: \"#{part.partName}\"\n"
    end
    @parts << part
    @partsHash[part.name] = part
  end

end

##__________________________________________________________________||
