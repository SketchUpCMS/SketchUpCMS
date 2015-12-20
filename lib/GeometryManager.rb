# Tai Sakuma <sakuma@fnal.gov>

##__________________________________________________________________||
class GeometryManager
  attr_accessor :materialsManager, :rotationsManager
  attr_accessor :solidsManager, :logicalPartsManager, :posPartsManager
  attr_accessor :partBuilder
  attr_reader :entries

  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @entries = Array.new
  end

  def add_entry sectionName, sectionLabel, partName, args
    # e.g. :SolidSection, "GeometryExtended", "Polycone", {"ZSection"= ... }
    inDDL = {:partName => partName.to_sym, :sectionLabel => sectionLabel.to_sym, :args => args}
    @entries << {:sectionName => sectionName, :inDDL => inDDL}
    add_inDDL_to_sectionManager sectionName, inDDL
  end

  def reload_from_cache
    @entries.each do |entry|
      add_inDDL_to_sectionManager entry[:sectionName],entry[:inDDL]
    end
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
      $stderr.write self.class.name + ": Unknown section: \"#{sectionName}\"\n"
      return
    end

    part = @partBuilder.build(sectionName, inDDL, self)
    sectionManagerMap[sectionName].add part

  end

end

##__________________________________________________________________||
