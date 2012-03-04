# Tai Sakuma <sakuma@fnal.gov>
require 'EntityDisplayer'

##____________________________________________________________________________||
class LogicalPart
  attr_accessor :geometryManager
  attr_accessor :name
  attr_accessor :partName
  attr_accessor :sectionLabel
  attr_accessor :argsInDDL
  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} #{@name}>"
  end
  def initialize geometryManager, partName, name
    @geometryManager = geometryManager
    @partName = partName
    @name = name
  end
  def clear
    @definition = nil
    @solid = nil if @solidName
    @solidName = nil if @argsInDDL
    @material = nil if @materialName
    @materialName = nil if @argsInDDL
    @parents = nil
    @children = nil
  end

  def definition
    return @definition if (@definition and (not @definition.deleted?))
    @definition = defineLogicalPart()
    @definition
  end

  attr_writer :solid
  def solid
    return @solid if @solid
    @solid = @geometryManager.solidsManager.get(solidName())
    @solid
  end

  attr_writer :solidName
  def solidName
    return @solidName if @solidName
    return @solid.name if @solid
    @solidName = baseNameName(@argsInDDL["rSolid"][0]["name"])
    @solidName
  end

  attr_writer :material
  def material
    return @material if @material
    @material = @geometryManager.materialsManager.getInSU(materialName())
    @material
  end

  attr_writer :materialName
  def materialName
    return @materialName if @materialName
    @materialName = baseNameName(@argsInDDL["rMaterial"][0]["name"])
    @materialName
  end

  def parents
    return @parents if @parents
    @parents = @geometryManager.posPartsManager.getByChild(@name)
    @parents
  end
  def children
    return @children if @children
    @children = @geometryManager.posPartsManager.getByParent(@name)
    @children
  end

  def defineLogicalPart

    return nil unless solid()

    solidDefinition = solid().definition

    group = Sketchup.active_model.entities.add_group

    transform = Geom::Transformation.new
    solidInstance = group.entities.add_instance solidDefinition, transform

    solidInstance.material = material()
    solidInstance.name = solidName().to_s + " "  + materialName().to_s

    lpInstance = group.to_component

    lpInstance.name = @name.to_s

    lpDefinition = lpInstance.definition
    lpDefinition.name = "lp_" + @name.to_s

    @geometryManager.logicalPartsManager.moveInstanceAway(lpInstance)
    lpDefinition

  end

  def placeChild childDefinition, transforms
    return unless definition()
    transforms.each {|t| definition().entities.add_instance childDefinition, t}
    return
  end
end

##____________________________________________________________________________||
class LogicalPartsManager
  attr_accessor :geometryManager
  attr_accessor :inDDLInOrderOfAddition
  attr_accessor :eraseAfterDefine
  attr_accessor :partsHash, :partsInOrderOfAddition
  attr_accessor :entityDisplayer
  attr_accessor :toHideList
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHash = Hash.new
    @partsInOrderOfAddition = Array.new
    @inDDLInOrderOfAddition = Array.new
    @eraseAfterDefine = true
    @toHideList = Array.new
  end
  def clear
    @entityDisplayer.clear
    @partsInOrderOfAddition.each {|p| p.clear }
  end
  def get(name)
    return nil unless @partsHash.key?(name)
    @partsHash[name]
  end
  def addPart name, part
    @partsInOrderOfAddition << part
    @partsHash[name] = part 
  end
  def addInDDL partName, sectionLabel, args
    inDDL = {:partName => partName, :sectionLabel => sectionLabel, :args => args}
    @inDDLInOrderOfAddition << inDDL
    addToPartsHash inDDL
  end
  def buildPartsHash
    @partsInOrderOfAddition = Array.new
    @partsHash = Hash.new
    @inDDLInOrderOfAddition.each {|inDDL| addToPartsHash inDDL}
  end
  def addToPartsHash inDDL
    name = inDDL[:args]['name'].to_sym
    part = buildPart(inDDL)
    addPart name, part 
  end
  def buildPart inDDL
    name = inDDL[:args]['name'].to_sym
    if inDDL[:partName] == :LogicalPart
      part = LogicalPart.new @geometryManager, inDDL[:partName], name
    else
      p "unknown partName #{inDDL[:partName]} #{name}"
      part = LogicalPart.new @geometryManager, inDDL[:partName], name
    end
    part.sectionLabel = inDDL[:sectionLabel]
    part.argsInDDL = inDDL[:args]
    part
  end
  def moveInstanceAway(instance)
    @entityDisplayer.display instance
    instance.erase! if @eraseAfterDefine
    instance
  end
end

##____________________________________________________________________________||
