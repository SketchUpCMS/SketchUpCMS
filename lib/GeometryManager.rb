# Tai Sakuma <sakuma@fnal.gov>

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
  attr_accessor :partBuilder
  attr_reader :inDDLs

  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @inDDLs = Array.new
  end

  def add_entry sectionName, sectionLabel, partName, args
    # e.g. :SolidSection, "GeometryExtended", "Polycone", {"ZSection"= ... }
    inDDL = {:partName => partName.to_sym, :sectionLabel => sectionLabel.to_sym, :args => args}
    @inDDLs << inDDL
    add_inDDL_to_sectionManager sectionName, inDDL
  end


  private

  def add_inDDL_to_sectionManager sectionName, inDDL

    sectionManagerMap = {
      :SolidSection => @solidsManager,
      :LogicalPartSection => @logicalPartsManager,
      :PosPartSection =>  @posPartsManager,
      :MaterialSection => @materialsManager,
      :RotationSection => @rotationsManager,
    }

    if ! sectionManagerMap.has_key?(sectionName)
      $stderr.puts self.class.name + ": Unknown section: \"#{sectionName}\"\n"
      return
    end

    part = @partBuilder.build(sectionName, inDDL, self)
    sectionManagerMap[sectionName].add part

  end

end

##____________________________________________________________________________||
