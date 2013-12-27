# Tai Sakuma <sakuma@fnal.gov>

require 'PosPart'

##____________________________________________________________________________||
class PosPartsManager
  attr_accessor :geometryManager
  attr_accessor :partsHashByParent
  attr_accessor :partsHashByChild
  attr_accessor :partsHashByParentChild
  attr_accessor :partsHashByParentChildCopy
  attr_accessor :parts

  KnownPartNames = [:PosPart]

  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHashByParent = Hash.new
    @partsHashByChild = Hash.new
    @partsHashByParentChild = Hash.new
    @partsHashByParentChildCopy = Hash.new
    @parts = Array.new
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
  def getByParentChildCopy(parentName, childName, copyNumber)
    @partsHashByParentChildCopy.key?([parentName, childName, copyNumber]) ? @partsHashByParentChildCopy[[parentName, childName, copyNumber]] : nil
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
    @partsHashByParentChildCopy[[part.parentName, part.childName, part.copyNumber]] = part
  end

end

##____________________________________________________________________________||
