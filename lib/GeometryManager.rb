# Tai Sakuma <sakuma@fnal.gov>
require 'RotationsManager'
require 'SolidsManager'
require 'LogicalPartsManager'
require 'PosPartsManager'
require 'MaterialsManager'

##____________________________________________________________________________||
def baseNameName(name)
  return name.to_sym
end

##____________________________________________________________________________||
def stringToSUNumeric(value)
  value = value.gsub(/([0-9]+)\.([^0-9]|$)/, '\1.0\2')
  value = value.gsub(/\*m/, '*1.m')
  value = value.gsub(/\*deg/, '*1.degrees')
  begin
    value = eval(value)
  rescue Exception => e
    puts e.message
    raise StandardError, "cannot eval \"#{value}\""
  end
  value
end

##____________________________________________________________________________||
class GeometryManager
  attr_accessor :materialsManager, :rotationsManager
  attr_accessor :solidsManager, :logicalPartsManager, :posPartsManager
  attr_reader :xmlFilePath

  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @inDDLs = Array.new
  end
  def xmlFilePath=(v)
    @xmlFilePath = v
    @baseName = File::basename(@xmlFilePath).sub(/\.xml/, '').to_sym
  end

  def add_entry sectionName, sectionLabel, partName, args
    inDDL = {:partName => partName.to_sym, :sectionLabel => sectionLabel.to_sym, :args => args}
    @inDDLs << inDDL
    add_inDDL_to_sectionManager sectionName, inDDL
  end


  private

  def add_inDDL_to_sectionManager sectionName, inDDL

    sectionBuilderMap = {
      :SolidSection => :buildSolidFromDDL,
      :LogicalPartSection => :buildLogicalPartFromDDL,
      :PosPartSection =>  :buildPosPartFromDDL,
      :MaterialSection => :buildMaterialFromDDL,
      :RotationSection => :buildRotationFromDDL,
    }

    sectionManagerMap = {
      :SolidSection => @solidsManager,
      :LogicalPartSection => @logicalPartsManager,
      :PosPartSection =>  @posPartsManager,
      :MaterialSection => @materialsManager,
      :RotationSection => @rotationsManager,
    }


    # begin
        part = send(sectionBuilderMap[sectionName], inDDL, self)
        sectionManagerMap[sectionName].add part
    # rescue Exception => e
    #   puts e.message
    #   p "#{self}: unable to add #{inDDL[:partName]}, args=", inDDL[:args]
    # end

  end

end

##____________________________________________________________________________||