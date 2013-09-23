# Tai Sakuma <sakuma@fnal.gov>

require 'RotationsManager'
require 'SolidsManager'
require 'LogicalPartsManager'
require 'PosPartsManager'
require 'MaterialsManager'


##____________________________________________________________________________||
class PartBuilder

  def buildRotationFromDDL(inDDL, geometryManager)
    part = Rotation.new geometryManager, inDDL[:partName]
    part.sectionLabel = inDDL[:sectionLabel]
    part.argsInDDL = inDDL[:args]
    part.name = inDDL[:args]['name'].to_sym
    part
  end

  def buildMaterialFromDDL(inDDL, geometryManager)
    part = Material.new geometryManager, inDDL[:partName]
    part.sectionLabel = inDDL[:sectionLabel]
    part.argsInDDL = inDDL[:args]
    part.name = inDDL[:args]['name'].to_sym
    part
  end

  def buildSolidFromDDL(inDDL, geometryManager)
    basicSolidNames = [:PseudoTrap, :Trd1, :Polycone, :Polyhedra, :Trapezoid, :Tubs, :Box, :Cone, :Torus]
    compoundSolidNames = [:UnionSolid, :SubtractionSolid]

    if basicSolidNames.include?(inDDL[:partName])
      part = BasicSolid.new geometryManager, inDDL[:partName]
    elsif compoundSolidNames.include?(inDDL[:partName])
      part = CompoundSolid.new geometryManager, inDDL[:partName]
    else
      part = UnknownSolid.new geometryManager, inDDL[:partName]
      p "#{self}: unknown solid #{inDDL[:partName]} #{part.name}"
    end
    part.sectionLabel = inDDL[:sectionLabel]
    part.argsInDDL = inDDL[:args]
    part.name = inDDL[:args]['name'].to_sym
    part
  end

  def buildLogicalPartFromDDL(inDDL, geometryManager)
    part = LogicalPart.new geometryManager, inDDL[:partName]
    part.sectionLabel = inDDL[:sectionLabel]
    part.argsInDDL = inDDL[:args]
    part.name = inDDL[:args]['name'].to_sym
    part.solidName = inDDL[:args]["rSolid"][0]["name"].to_sym
    part.materialName = inDDL[:args]["rMaterial"][0]["name"].to_sym
    part
  end

  def buildPosPartFromDDL(inDDL, geometryManager)
    part = PosPart.new geometryManager, inDDL[:partName]
    part.sectionLabel = inDDL[:sectionLabel]
    part.argsInDDL = inDDL[:args]
    part.parentName = inDDL[:args]["rParent"][0]["name"].to_sym
    part.childName = inDDL[:args]["rChild"][0]["name"].to_sym
    part.rotationName = inDDL[:args]["rRotation"] ? inDDL[:args]["rRotation"][0]["name"].to_sym : nil
    part.translation = inDDL[:args]["Translation"] ? inDDL[:args]["Translation"][0] : {"z"=>"0*mm", "y"=>"0*mm", "x"=>"0*mm"}
    part
  end

  SECTIONBUILDERMAP = {
    :SolidSection => :buildSolidFromDDL,
    :LogicalPartSection => :buildLogicalPartFromDDL,
    :PosPartSection =>  :buildPosPartFromDDL,
    :MaterialSection => :buildMaterialFromDDL,
    :RotationSection => :buildRotationFromDDL,
  }

  def build(sectionName, inDDL, geometryManager)
    send(SECTIONBUILDERMAP[sectionName], inDDL, geometryManager)
  end
end

##____________________________________________________________________________||
