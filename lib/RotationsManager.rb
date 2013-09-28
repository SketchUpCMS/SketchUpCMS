# Tai Sakuma <sakuma@fnal.gov>

require 'Rotation'

##____________________________________________________________________________||
class RotationsManager
  attr_accessor :geometryManager
  attr_accessor :partsHash, :parts

  KnownPartNames = [:Rotation, :ReflectionRotation]

  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHash = Hash.new
    @parts = Array.new
  end
  def clear
    @parts.each {|p| p.clear if p}
  end
  def get(name)
    @partsHash.key?(name) ? @partsHash[name] : nil
  end
  def add part
    if ! KnownPartNames.include?(part.partName)
      $stderr.write self.class.name + ": Unknown part name: \"#{part.partName}\"\n"
      return
    end
    @parts << part
    @partsHash[part.name] = part 
  end
end

##____________________________________________________________________________||
