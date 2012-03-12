# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
class PosPart
  attr_accessor :geometryManager
  attr_accessor :partName
  attr_accessor :sectionLabel
  attr_accessor :parentName, :childName
  attr_accessor :parent, :child
  attr_accessor :done
  attr_accessor :argsInDDL
  attr_writer :rotation, :translation

  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} parent=#{parentName()} child=#{childName()}>"
  end
  def initialize geometryManager, partName
    @geometryManager = geometryManager
    @partName = partName
    @done = false
  end
  def clear
    @done = false
    @parent = nil
    @child = nil
    @rotation = nil
    @translation = nil
  end
  def parent
    return @parent if @parent
    @parent = @geometryManager.logicalPartsManager.get(parentName())
    p "#{self}: not found: #{parentName()}" unless @parent
    @parent
  end
  def child
    return @child if @child
    @child = @geometryManager.logicalPartsManager.get(childName())
    p "#{self}: not found: #{childName()}" unless @child
    @child
  end
  def exec
    return if @done
    doPosPart()
    @done = true
  end
  def rotation
    return @rotation if @rotation
    if @argsInDDL and @argsInDDL.key?("rRotation")
      name = @argsInDDL["rRotation"][0]["name"].to_sym
      @rotation = @geometryManager.rotationsManager.get(name).transformation
    else
      @rotation = Geom::Transformation.new
    end
    @rotation
  end
  def translation
    return @translation if @translation
    if @argsInDDL and @argsInDDL.key?("Translation")
      x = stringToSUNumeric(@argsInDDL["Translation"][0]['x'])
      y = stringToSUNumeric(@argsInDDL["Translation"][0]['y'])
      z = stringToSUNumeric(@argsInDDL["Translation"][0]['z'])
      vector = Geom::Vector3d.new z, x, y
      @translation = Geom::Transformation.translation vector
    else
      @translation =  Geom::Transformation.new
    end
    @translation
  end
  def doPosPart
    transform = translation()*rotation()
    child = child()
    return unless child
    childDefinition = child.definition
    return unless childDefinition
    parent().placeChild(childDefinition, [transform])
  end

end

##____________________________________________________________________________||
def buildPosPartFromDDL(inDDL, geometryManager)
  part = PosPart.new geometryManager, inDDL[:partName]
  part.sectionLabel = inDDL[:sectionLabel]
  part.argsInDDL = inDDL[:args]
  part.parentName = inDDL[:args]["rParent"][0]["name"].to_sym
  part.childName = inDDL[:args]["rChild"][0]["name"].to_sym
  part
end

##____________________________________________________________________________||
class PosPartsManager
  attr_accessor :geometryManager
  attr_accessor :partsHashByParent
  attr_accessor :partsHashByChild
  attr_accessor :partsInOrderOfAddition

  KnownPartNames = [:PosPart]

  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHashByParent = Hash.new
    @partsHashByChild = Hash.new
    @partsInOrderOfAddition = Array.new
  end
  def clear
    @partsInOrderOfAddition.each {|p| p.clear }
  end
  def getByParent(name)
    @partsHashByParent.key?(name) ? @partsHashByParent[name] : [ ]
  end
  def getByChild(name)
    @partsHashByChild.key?(name) ? @partsHashByChild[name] : [ ]
  end
  def addInDDL inDDL
    raise StandardError, "unknown part name \"#{partName}\"" unless KnownPartNames.include?(inDDL[:partName])
    part = buildPosPartFromDDL(inDDL, @geometryManager)
    @partsInOrderOfAddition << part
    @partsHashByParent[part.parentName] = Array.new unless @partsHashByParent.key?(part.parentName)
    @partsHashByParent[part.parentName] << part
    @partsHashByChild[part.childName] = Array.new unless @partsHashByChild.key?(part.childName)
    @partsHashByChild[part.childName] << part
  end

end

##____________________________________________________________________________||
