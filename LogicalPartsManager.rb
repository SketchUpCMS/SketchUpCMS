# Tai Sakuma <sakuma@fnal.gov>
require 'EntityDisplayer'

##____________________________________________________________________________||
class LogicalPart
  attr_accessor :geometryManager
  attr_accessor :name
  attr_accessor :partName
  attr_accessor :sectionLabel
  attr_accessor :solidName
  attr_accessor :materialName
  attr_accessor :argsInDDL
  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} #{@name}>"
  end
  def initialize geometryManager, partName
    @geometryManager = geometryManager
    @partName = partName
  end
  def clear
    @definition = nil
    @solidInstance = nil
    @solid = nil
    @material = nil
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
    @material = @geometryManager.materialsManager.get(materialName()).inSU
    @material
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
    # @solidInstance.material = material()
    @solidInstance.name = @solidName.to_s + " "  + materialName().to_s
  end

  def defineFromGroup group
    lpInstance = group.to_component
    lpInstance.name = @name.to_s

    lpDefinition = lpInstance.definition
    lpDefinition.name = "lp_" + @name.to_s

    @geometryManager.logicalPartsManager.moveInstanceAway(lpInstance)
    lpDefinition
  end

  def placeChild child, translation, rotation

    # translation
    x = stringToSUNumeric(translation['x'])
    y = stringToSUNumeric(translation['y'])
    z = stringToSUNumeric(translation['z'])
    vector = Geom::Vector3d.new z, x, y
    translation = Geom::Transformation.translation vector

    rotation = rotation ? rotation.transformation : Geom::Transformation.new

    transform = translation*rotation
    childDefinition = child.definition
    return unless childDefinition
    if (@definition and (not @definition.deleted?))
      entities = @definition.entities
      entities.add_instance childDefinition, transform
    else
      group = Sketchup.active_model.entities.add_group
      entities = group.entities
      entities.add_instance childDefinition, transform
      @definition = defineFromGroup group
    end
    return
  end
end

##____________________________________________________________________________||
def buildLogicalPartFromDDL(inDDL, geometryManager)
  part = LogicalPart.new geometryManager, inDDL[:partName]
  part.sectionLabel = inDDL[:sectionLabel]
  part.argsInDDL = inDDL[:args]
  part.name = inDDL[:args]['name'].to_sym
  part.solidName = inDDL[:args]["rSolid"][0]["name"].to_sym
  part.materialName = inDDL[:args]["rMaterial"][0]["name"].to_sym
  part
end

##____________________________________________________________________________||
class LogicalPartsManager
  attr_accessor :geometryManager
  attr_accessor :eraseAfterDefine
  attr_accessor :partsHash, :parts
  attr_accessor :entityDisplayer

  KnownPartNames = [:LogicalPart]

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
    @parts.each {|p| p.clear }
  end
  def get(name)
    @partsHash.key?(name)? @partsHash[name] : nil
  end
  def add part
    raise StandardError, "unknown part name \"#{partName}\"" unless KnownPartNames.include?(part.partName)
    @parts << part
    @partsHash[part.name] = part 
  end
  def moveInstanceAway(instance)
    @entityDisplayer.display instance
    instance.erase! if @eraseAfterDefine
    instance
  end
end

##____________________________________________________________________________||
