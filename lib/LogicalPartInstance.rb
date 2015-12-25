# Tai Sakuma <sakuma@fnal.gov>

require 'LogicalPartDefiner'

##__________________________________________________________________||
class LogicalPartInstance
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

  def initialize dd
    @geometryManager = dd.geometryManager
    @partName = dd.partName
    @solidName = dd.solidName
    @materialName = dd.materialName
    @children = [ ]
  end

  def definition
    return @definition if (@definition and (not @definition.deleted?))
    return nil
  end

  def solid
    return @solid if @solid
    @solid = @geometryManager.solidsManager.get(@solidName)
    p "#{self}: not found: #{@solidName}" unless @solid
    @solid
  end

  attr_writer :material

  def material
    return @material if @material
    @material = @geometryManager.materialsManager.get(@materialName).inSU
    p "#{self}: not found: #{@materialName}" unless @material
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
