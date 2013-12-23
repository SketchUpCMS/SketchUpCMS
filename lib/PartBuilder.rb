# Tai Sakuma <sakuma@fnal.gov>

require 'RotationsManager'
require 'SolidsManager'
require 'LogicalPartsManager'
require 'PosPartsManager'
require 'MaterialsManager'


##____________________________________________________________________________||
class PartBuilder

  def buildRotationFromDDL(inDDL, geometryManager)
    # e.g.,
    # inDDL = {
    #   :sectionLabel=>:GeometryExtended, :partName=>:Rotation,
    #   :args=>{"name"=>"DdBlNa:DdBlNa1306",
    #     "phiZ"=>"0.00*deg", "phiY"=>"90.00*deg", "phiX"=>"0.00*deg",
    #     "thetaZ"=>"0.00*deg", "thetaY"=>"90.00*deg", "thetaX"=>"90.00*deg"}
    # }
    part = Rotation.new geometryManager, inDDL[:partName]
    part.argsInDDL = inDDL[:args]
    part.name = inDDL[:args]['name'].to_sym
    part
  end

  def buildMaterialFromDDL(inDDL, geometryManager)
    # e.g.,
    # inDDL = {
    #   :sectionLabel=>:GeometryExtended, :partName=>:ElementaryMaterial,
    #   :args=>{
    #     "atomicWeight"=>"12.01099*g/mole",
    #     "name"=>"materials:Carbon",
    #     "atomicNumber"=>"6",
    #     "density"=>"2.26500e+03*mg/cm3"
    #   }
    # }
    # inDDL = {:sectionLabel=>:GeometryExtended, :partName=>:CompositeMaterial,
    #   :args=>{
    #     "method"=>"mixture by weight",
    #     "MaterialFraction"=>[{"fraction"=>"0.749400000"},
    #                          {"fraction"=>"0.236900000"},
    #                          {"fraction"=>"0.012900000"},
    #                          {"fraction"=>"0.000800000"}],
    #     "name"=>"materials:Air",
    #     "rMaterial"=>[{"name"=>"materials:Nitrogen"},
    #                   {"name"=>"materials:Oxygen"},
    #                   {"name"=>"materials:Argon"},
    #                   {"name"=>"materials:Hydrogen"}],
    #     "density"=>"1.21400e+00*mg/cm3"}
    # }

    part = Material.new geometryManager, inDDL[:partName]
    part.argsInDDL = inDDL[:args]
    part.name = inDDL[:args]['name'].to_sym
    part
  end

  def buildSolidFromDDL(inDDL, geometryManager)
    # e.g.,
    # inDDL = {
    #   :sectionLabel=>:GeometryExtended, :partName=>:Tubs,
    #   :args=>{
    #     "dz"=>"830.00*mm", "deltaPhi"=>"9.00*deg",
    #     "rMax"=>"1169.00*mm", "rMin"=>"1160.00*mm",
    #     "startPhi"=>"141.00*deg",
    #     "name"=>"tob:TOBAxService_8C"}}
    #
    # inDDL = {
    #   :sectionLabel=>:GeometryExtended, :partName=>:SubtractionSolid,
    #   :args=>{
    #     "rRotation"=>[{"name"=>"rotations:RMCHIMHOLEN"}],
    #     "rSolid"=>[{"name"=>"mgnt:MGNT_1"}, {"name"=>"mgnt:CHIMNEY_HOLE_N"}],
    #     "Translation"=>[{"z"=>"-1560.00*mm", "y"=>"2931.495991810324994731*mm", "x"=>"1692.499999999999772626*mm"}],
    #     "name"=>"mgnt:MGNT"}}

    part = Solid.new geometryManager, inDDL[:partName]
    part.argsInDDL = inDDL[:args]
    part.name = inDDL[:args]['name'].to_sym
    part
  end

  def buildLogicalPartFromDDL(inDDL, geometryManager)
    # e.g.,
    # inDDL = {
    #   :sectionLabel=>:GeometryExtended, :partName=>:LogicalPart,
    #   :args=>{
    #     "rMaterial"=>[{"name"=>"materials:Air"}],
    #     "name"=>"tracker:Tracker",
    #     "rSolid"=>[{"name"=>"tracker:Tracker"}]}}

    part = LogicalPart.new geometryManager, inDDL[:partName]
    part.argsInDDL = inDDL[:args]
    part.name = inDDL[:args]['name'].to_sym
    part.solidName = inDDL[:args]["rSolid"][0]["name"].to_sym
    part.materialName = inDDL[:args]["rMaterial"][0]["name"].to_sym
    part
  end

  def buildPosPartFromDDL(inDDL, geometryManager)
    # e.g.,
    # inDDL = {
    #   :sectionLabel=>:GeometryTOB, :partName=>:PosPart,
    #   :args=>{
    #     "copyNumber"=>"4",
    #     "rChild"=>[{"name"=>"tobmodule0:TOBModule0"}],
    #     "rParent"=>[{"name"=>"tobrod1l:TOBRodCentral1L"}],
    #     "Translation"=>[{"z"=>"77.086*mm", "y"=>"-5.425*mm", "x"=>"0.00*mm"}],
    #     "rRotation"=>[{"name"=>"tobrodpar:180X"}]}}

    part = PosPart.new geometryManager, inDDL[:partName]
    part.argsInDDL = inDDL[:args]
    part.parentName = inDDL[:args]["rParent"][0]["name"].to_sym
    part.childName = inDDL[:args]["rChild"][0]["name"].to_sym
    part.copyNumber = inDDL[:args]["copyNumber"].to_i
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
