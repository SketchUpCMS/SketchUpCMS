# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
class PosPart
  attr_accessor :geometryManager
  attr_accessor :partName
  attr_accessor :sectionLabel
  attr_writer :parentName
  attr_writer :childName
  attr_accessor :done
  attr_accessor :argsInDDL
  attr_accessor :parent, :child
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
    @parentName = nil
    @childName = nil
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
  def parentName
    return @parentName if @parentName
    return @parent.name if @parent
    @parentName = baseNameName(@argsInDDL["rParent"][0]["name"])
    @parentName
  end
  def childName
    return @childName if @childName
    return @child.name if @child
    @childName = baseNameName(@argsInDDL["rChild"][0]["name"])
    @childName
  end

  def exec
    return if @done
    doPosPart()
    @done = true
  end
  def rotation
    return @rotation if @rotation
    if @argsInDDL and @argsInDDL.key?("rRotation")
      name = baseNameName(@argsInDDL["rRotation"][0]["name"])
      @rotation = @geometryManager.rotationsManager.get(name).transformation
    else
      @rotation = Geom::Transformation.new
    end
    @rotation
  end
  def translation
    return @translation if @translation
    if @argsInDDL and @argsInDDL.key?("Translation")
      x = @geometryManager.constantsManager.inSU(@argsInDDL["Translation"][0]['x'])
      y = @geometryManager.constantsManager.inSU(@argsInDDL["Translation"][0]['y'])
      z = @geometryManager.constantsManager.inSU(@argsInDDL["Translation"][0]['z'])
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
class PosPartsManager
  attr_accessor :geometryManager
  attr_accessor :inDDLInOrderOfAddition
  attr_accessor :partsHashByParent
  attr_accessor :partsHashByChild
  attr_accessor :partsInOrderOfAddition
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHashByParent = Hash.new
    @partsHashByChild = Hash.new
    @partsInOrderOfAddition = Array.new
    @inDDLInOrderOfAddition = Array.new
  end
  def clear
    @partsInOrderOfAddition.each {|p| p.clear }
  end
  def getByParent(name)
    return [] unless @partsHashByParent.key?(name)
    parts = @partsHashByParent[name]
    parts
  end
  def getByChild(name)
    return [] unless @partsHashByChild.key?(name)
    parts = @partsHashByChild[name]
    parts
  end
  def addPart part 
    @partsInOrderOfAddition << part
    @partsHashByParent[part.parentName] = Array.new unless @partsHashByParent.key?(part.parentName)
    @partsHashByParent[part.parentName] << part
    @partsHashByChild[part.childName] = Array.new unless @partsHashByChild.key?(part.childName)
    @partsHashByChild[part.childName] << part
  end
  def addInDDL partName, sectionLabel, args
    knownPartNames = [:PosPart]
    raise StandardError, "unknown part name \"#{partName}\"" unless knownPartNames.include?(partName)
    inDDL = {:partName => partName, :sectionLabel => sectionLabel, :args => args}
    @inDDLInOrderOfAddition << inDDL
    addToPartsHash inDDL
  end
  def buildPartsHash
    @partsInOrderOfAddition = Array.new
    @partsHashByParent = Hash.new
    @partsHashByChild = Hash.new
    @inDDLInOrderOfAddition.each {|inDDL| addToPartsHash inDDL}
  end
  def addToPartsHash inDDL
    part = buildPart(inDDL)
    addPart part 
  end
  def buildPart inDDL
    part = PosPart.new @geometryManager, inDDL[:partName]
    part.sectionLabel = inDDL[:sectionLabel]
    part.argsInDDL = inDDL[:args]
    part
  end
  def execute
    @inDDLInOrderOfAddition.each {|inDDL| execInDDL inDDL }
  end

end

##____________________________________________________________________________||
