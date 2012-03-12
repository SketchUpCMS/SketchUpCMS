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
    @solidInstance = nil
    @solid = nil
    @solidName = nil
    @material = nil
    @materialName = nil
    @parents = nil
    @children = nil
  end

  def definition
    return @definition if (@definition and (not @definition.deleted?))
    return nil
  end

  def solid
    return @solid if @solid
    @solid = @geometryManager.solidsManager.get(solidName())
    @solid
  end

  def solidName
    return @solidName if @solidName
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

  def instantiateSolid
    return if @solidInstance
    return unless solid()

    solidDefinition = solid().definition

    if (@definition and (not @definition.deleted?))
      entities = @definition.entities
      instantiateSolidInEntities solidDefinition, entities
    else
      group = Sketchup.active_model.entities.add_group
      entities = group.entities
      instantiateSolidInEntities solidDefinition, entities
      @definition = defineFromGroup group
    end
  end

  def instantiateSolidInEntities solidDefinition, entities
    transform = Geom::Transformation.new
    @solidInstance = entities.add_instance solidDefinition, transform
    @solidInstance.material = material()
    @solidInstance.name = solidName().to_s + " "  + materialName().to_s
  end

  def defineFromGroup group
    lpInstance = group.to_component
    lpInstance.name = @name.to_s

    lpDefinition = lpInstance.definition
    lpDefinition.name = "lp_" + @name.to_s

    @geometryManager.logicalPartsManager.moveInstanceAway(lpInstance)
    lpDefinition
  end

  def placeChild childDefinition, transforms
    if (@definition and (not @definition.deleted?))
      entities = @definition.entities
      transforms.each {|t| entities.add_instance childDefinition, t}
    else
      group = Sketchup.active_model.entities.add_group
      entities = group.entities
      transforms.each {|t| entities.add_instance childDefinition, t}
      @definition = defineFromGroup group
    end
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
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHash = Hash.new
    @partsInOrderOfAddition = Array.new
    @inDDLInOrderOfAddition = Array.new
    @eraseAfterDefine = true
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
  def addInDDL inDDL
    @inDDLInOrderOfAddition << inDDL
    addToPartsHash inDDL
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
