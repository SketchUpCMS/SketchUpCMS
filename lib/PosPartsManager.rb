# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
class PosPart
  attr_accessor :geometryManager
  attr_accessor :partName
  attr_accessor :sectionLabel
  attr_accessor :parentName, :childName
  attr_accessor :rotationName
  attr_accessor :translation
  attr_accessor :done
  attr_accessor :argsInDDL
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
  end
  def parent
    return @parent if @parent
    @parent = @geometryManager.logicalPartsManager.get(@parentName)
    p "#{self}: not found: #{@parentName}" unless @parent
    @parent
  end
  def child
    return @child if @child
    @child = @geometryManager.logicalPartsManager.get(@childName)
    p "#{self}: not found: #{@childName}" unless @child
    @child
  end
  def exec
    return if @done
    child = child()
    return unless child
    parent().placeChild(child, translation(), rotation())
    @done = true
  end
  def rotation
    return @rotation if @rotation
    if @rotationName
      @rotation = @geometryManager.rotationsManager.get(@rotationName)
      p "#{self}: not found: #{@rotationName}" unless @rotation
    else
      @rotation = nil
    end
    @rotation
  end
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
