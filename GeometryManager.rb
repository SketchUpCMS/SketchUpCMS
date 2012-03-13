# Tai Sakuma <sakuma@fnal.gov>
require 'RotationsManager'
require 'SolidsManager'
require 'LogicalPartsManager'
require 'PosPartsManager'

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
class Material
  attr_accessor :geometryManager
  attr_accessor :name
  attr_accessor :partName
  attr_accessor :sectionLabel
  attr_accessor :argsInDDL
  attr_accessor :defaultColor
  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} #{@name}>"
  end
  def initialize geometryManager, partName
    @geometryManager = geometryManager
    @partName = partName
    @defaultColor = 'silver'
  end
  def inSU
    return @inSU if @inSU
    begin
      @inSU = ddlToSU(@argsInDDL)
    rescue Exception => e
      puts e.message
    end
    @inSU
  end
  def ddlToSU args
    materials = Sketchup.active_model.materials
    m = materials.add args['name']
    m.color = @defaultColor
    m.color = eval(args['color']) if args.key?('color')
    m.alpha = eval(args['alpha']) if args.key?('alpha')
    # 'M_Steel-008'
    # m.color = 0x333399
    p m
    m
  end
end

##____________________________________________________________________________||
def buildMaterialFromDDL(inDDL, geometryManager)
  part = Material.new geometryManager, inDDL[:partName]
  part.sectionLabel = inDDL[:sectionLabel]
  part.argsInDDL = inDDL[:args]
  part.name = inDDL[:args]['name'].to_sym
  part
end

##____________________________________________________________________________||
class MaterialsManager
  attr_accessor :geometryManager
  attr_accessor :partsHash, :partsInOrderOfAddition
  attr_accessor :defaultColor
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHash = Hash.new
    @partsInOrderOfAddition = Array.new
    clear
  end
  def clear
    @defaultColor = 'silver'
  end
  def addInDDL inDDL
    part = buildMaterialFromDDL(inDDL, @geometryManager)
    @partsInOrderOfAddition << part
    @partsHash[part.name] = part 
  end
  def get(name)
    @partsHash.key?(name) ? @partsHash[name] : nil
  end
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

    sectionManagerMap = {
      :SolidSection => @solidsManager,
      :LogicalPartSection => @logicalPartsManager,
      :PosPartSection =>  @posPartsManager,
      :MaterialSection => @materialsManager,
      :RotationSection => @rotationsManager,
    }

    # begin
       sectionManagerMap[sectionName].addInDDL inDDL
    # rescue Exception => e
    #   puts e.message
    #   p "#{self}: unable to add #{inDDL[:partName]}, args=", inDDL[:args]
    # end

  end

end

##____________________________________________________________________________||
