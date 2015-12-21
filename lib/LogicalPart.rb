# Tai Sakuma <sakuma@fnal.gov>

require 'LogicalPartDefiner'

##__________________________________________________________________||
class LogicalPart
  attr_accessor :geometryManager
  attr_accessor :name
  attr_accessor :partName
  attr_accessor :solidName
  attr_accessor :materialName
  attr_accessor :argsInDDL
  attr_accessor :children
  attr_accessor :solidInPlace

  # example,
  #   name = :"tracker:Tracker"
  #   partName = :LogicalPart
  #   solidName = :"tracker:Tracker"
  #   materialName = :"materials:Air"
  #   argsInDDL = {
  #     "rMaterial"=>[{"name"=>"materials:Air"}],
  #     "name"=>"tracker:Tracker",
  #     "rSolid"=>[{"name"=>"tracker:Tracker"}]}

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

    definer = LogicalPartDefiner.new
    @definition = definer.define(@name, @children, @solidInPlace, @solidName, @materialName)

  end

end

##__________________________________________________________________||
