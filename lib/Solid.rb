# Tai Sakuma <sakuma@fnal.gov>

require 'SolidDefiner'

##__________________________________________________________________||
class Solid
  attr_accessor :geometryManager
  attr_accessor :name
  attr_accessor :partName
  attr_accessor :argsInDDL

  # example, basic solid
  #   name = :"tob:TOBAxService_8C"
  #   partName = :Tubs
  #   argsInDDL = {
  #     "dz"=>"830.00*mm", "deltaPhi"=>"9.00*deg",
  #     "rMax"=>"1169.00*mm", "rMin"=>"1160.00*mm",
  #     "startPhi"=>"141.00*deg",
  #     "name"=>"tob:TOBAxService_8C"}
  #
  # example, compound solid
  #   name = :"mgnt:MGNT"
  #   partName = :SubtractionSolid
  #   argsInDDL = {
  #     "rRotation"=>[{"name"=>"rotations:RMCHIMHOLEN"}],
  #     "rSolid"=>[{"name"=>"mgnt:MGNT_1"}, {"name"=>"mgnt:CHIMNEY_HOLE_N"}],
  #     "Translation"=>[{"z"=>"-1560.00*mm", "y"=>"2931.495991810324994731*mm", "x"=>"1692.499999999999772626*mm"}],
  #     "name"=>"mgnt:MGNT"}
  #

  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} #{@name}>"
  end

  def initialize geometryManager, partName
    @geometryManager = geometryManager
    @partName = partName
  end

  def definition
    return @definition if (@definition and (not @definition.deleted?))
    @definition = defineSolid()
    @definition
  end

  def defineSolid
    begin
      definer = SolidDefiner.new(@geometryManager)
      return definer.define(@partName, @name, @argsInDDL)
    rescue Exception => e
      $stderr.write e.message + "\n"
      $stderr.write self.class.name + ": Unable to defineSolid: #{@name}\n"
      return nil
    end
  end

end

##__________________________________________________________________||
