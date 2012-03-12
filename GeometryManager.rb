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
class MaterialsManager
  attr_accessor :geometryManager
  attr_accessor :inSUHash
  attr_accessor :defaultMaterial, :defaultColor
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @inDDLHash = Hash.new

    # @defaultMaterial = Sketchup.active_model.materials.add 'defaultMaterial'

    clear
  end
  def clear
    @inSUHash = Hash.new
    @defaultColor = 'silver'
    # @defaultMaterial.color = @defaultColor
  end
  def addInDDL inDDL
    name = inDDL[:args]['name'].to_sym
    @inDDLHash[name] = inDDL
  end
  def getInDDL(name)
    raise StandardError, "no such name \"#{name}\"" unless @inDDLHash.key?(name)
    ret = @inDDLHash[name]
    ret
  end
  def getInSU name
    if @inSUHash.key?(name)
      inSU = @inSUHash[name] 
      return inSU
    end
    begin
      inDDL = getInDDL(name)
      inSU = ddlToSU(inDDL)
    rescue Exception => e
      puts e.message
      # inSU = @defaultMaterial
    end
    @inSUHash[name] = inSU
    inSU
  end
  def ddlToSU inDDL
    args = inDDL[:args]
    materials = Sketchup.active_model.materials
    m = materials.add args['name']
    m.color = @defaultColor
    m.color = eval(args['color']) if args.key?('color')
    m.alpha = eval(args['alpha']) if args.key?('alpha')
    # 'M_Steel-008'
    # m.color = 0x333399
    m
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

    begin
      sectionManagerMap[sectionName].addInDDL inDDL
    rescue Exception => e
      puts e.message
      p "#{self}: unable to add #{inDDL[:partName]}, args=", inDDL[:args]
    end

  end

end

##____________________________________________________________________________||
