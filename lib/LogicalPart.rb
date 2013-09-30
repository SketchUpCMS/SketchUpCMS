# Tai Sakuma <sakuma@fnal.gov>

require 'LogicalPartDefiner'

##____________________________________________________________________________||
class LogicalPart
  attr_accessor :geometryManager
  attr_accessor :name
  attr_accessor :partName
  attr_accessor :solidName
  attr_accessor :materialName
  attr_accessor :argsInDDL
  attr_accessor :children
  attr_accessor :solidInPlace
  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} #{@name}>"
  end
  def initialize geometryManager, partName
    @geometryManager = geometryManager
    @partName = partName
    @children = [ ]
  end
  def definition
    return @definition if (@definition and (not @definition.deleted?))
    return nil
  end

  def solid
    return @solid if @solid
    @solid = @geometryManager.solidsManager.get(@solidName)
    @solid
  end

  attr_writer :material
  def material
    return @material if @material
    @material = @geometryManager.materialsManager.get(@materialName).inSU
    @material
  end

  def placeSolid 
    @solidInPlace = solid()
  end

  def placeChild child, translation, rotation
    @children << {:child => child, :translation => translation, :rotation => rotation }
  end

  def define
    return if (@definition and (not @definition.deleted?))

    definer = LogicalPartDefiner.new(@geometryManager)
    @definition = definer.define(@name, @children, @solidInPlace, @solidName, @materialName)

  end

end

##____________________________________________________________________________||
