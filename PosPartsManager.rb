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
      @rotation = @geometryManager.rotationsManager.get(name)
    else
      @rotation = nil
    end
    @rotation
  end
  def translation
    return @translation if @translation
    @translation = (@argsInDDL and @argsInDDL.key?("Translation")) ? @argsInDDL["Translation"][0] : {"z"=>"0*mm", "y"=>"0*mm", "x"=>"0*mm"}
    @translation
  end
  def doPosPart
    child = child()
    return unless child
    parent().placeChild(child, translation(), rotation())
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
  attr_accessor :partsHashByParentChild
  attr_accessor :parts

  KnownPartNames = [:PosPart]

  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHashByParent = Hash.new
    @partsHashByChild = Hash.new
    @partsHashByParentChild = Hash.new
    @parts = Array.new
  end
  def clear
    @parts.each {|p| p.clear }
  end
  def getByParent(name)
    @partsHashByParent.key?(name) ? @partsHashByParent[name] : [ ]
  end
  def getByChild(name)
    @partsHashByChild.key?(name) ? @partsHashByChild[name] : [ ]
  end
  def getByParentChild(parentName, childName)
    @partsHashByParentChild.key?([parentName, childName]) ? @partsHashByParentChild[[parentName, childName]] : [ ]
  end
  def add part
    raise StandardError, "unknown part name \"#{partName}\"" unless KnownPartNames.include?(part.partName)
    @parts << part
    @partsHashByParent[part.parentName] = Array.new unless @partsHashByParent.key?(part.parentName)
    @partsHashByParent[part.parentName] << part
    @partsHashByChild[part.childName] = Array.new unless @partsHashByChild.key?(part.childName)
    @partsHashByChild[part.childName] << part
    @partsHashByParentChild[[part.parentName, part.childName]] = Array.new unless @partsHashByParentChild.key?([part.parentName, part.childName])
    @partsHashByParentChild[[part.parentName, part.childName]] << part
  end

end

##____________________________________________________________________________||
