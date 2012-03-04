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
class MaterialsManager
  attr_accessor :geometryManager
  attr_accessor :inDDLInOrderOfAddition
  attr_accessor :inSUHash
  attr_accessor :defaultMaterial, :defaultColor
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @inDDLHash = Hash.new
    @inDDLInOrderOfAddition = Array.new

    # @defaultMaterial = Sketchup.active_model.materials.add 'defaultMaterial'

    clear
  end
  def clear
    @inSUHash = Hash.new
    @defaultColor = 'silver'
    # @defaultMaterial.color = @defaultColor
  end
  def addInDDL type, sectionLabel, args
    inDDL = {:type => type, :sectionLabel => sectionLabel, :args => args}
    @inDDLInOrderOfAddition << inDDL
    name = args['name'].to_sym
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
class ConstantsManager
  attr_accessor :geometryManager
  attr_accessor :inDDLInOrderOfAddition
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @inDDLHash = Hash.new
    @inDDLInOrderOfAddition = Array.new
  end
  def addInDDL type, sectionLabel, args
    @inDDLInOrderOfAddition << {:sectionLabel => sectionLabel, :args => args}
    name, value = args["name"], args["value"]
    name = name.to_sym
    value = value.gsub(/\r/," ")
    value = value.gsub(/\n/," ")
    @inDDLHash[name] = value
  end
  def get(name)
    raise StandardError, "no such constant \"#{name}\"" unless @inDDLHash.key?(name)
    ret = @inDDLHash[name]
    ret
  end
  def expand(value)
    begin
      ret = value
      maxLoop = 100
      re = /^[^\[]*\[([^\]]*)\].*$/
      while ret =~ re
        name = ret.sub(re, '\1')
        nameV = name.to_sym
        v1 = get(nameV)
        v1 = expand(v1)
        ret = ret.sub('[' + name + ']', '(' + v1 + ')')
        maxLoop -= 1
        raise StandardError, "too many loops" if maxLoop <= 0 
      end
      return ret
    rescue Exception => e
      puts e.message
      raise StandardError, "cannot expand \"#{value}\""
    end
    value
  end
  def inSU(value)
    value = inSUstring(value)
    begin
      value = eval(value)
    rescue Exception => e
      puts e.message
      raise StandardError, "cannot eval \"#{value}\""
    end
    value
  end
  def inSUstring(value)
    value = expand(value)
    value = value.gsub(/([0-9]+)\.([^0-9]|$)/, '\1.0\2')

    value = value.gsub(/\*m/, '*1.m')
    value = value.gsub(/\*deg/, '*1.degrees')

    value
  end
end


##____________________________________________________________________________||
class GeometryManager
  attr_accessor :materialsManager, :rotationsManager, :constantsManager
  attr_accessor :solidsManager, :logicalPartsManager, :posPartsManager
  attr_reader :xmlFilePath
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def xmlFilePath=(v)
    @xmlFilePath = v
    @baseName = File::basename(@xmlFilePath).sub(/\.xml/, '').to_sym
  end
  def add_constant sectionName, sectionLabel, partName, args
    @constantsManager.addInDDL partName.to_sym, sectionLabel.to_sym, args
  end

  def add_rotation sectionName, sectionLabel, partName, args
    @rotationsManager.addInDDL partName.to_sym, sectionLabel.to_sym, args
  end

  def add_geometry sectionName, sectionLabel, partName, args
    begin
      if sectionName == "SolidSection"
        @solidsManager.addInDDL partName.to_sym, sectionLabel.to_sym, args
      elsif sectionName == "LogicalPartSection"
        @logicalPartsManager.addInDDL partName.to_sym, sectionLabel.to_sym, args
      elsif sectionName == "PosPartSection"
        @posPartsManager.addInDDL partName.to_sym, sectionLabel.to_sym, args
      elsif sectionName == "MaterialSection"
        @materialsManager.addInDDL partName.to_sym, sectionLabel.to_sym, args
      end
    rescue Exception => e
      puts e.message
      p "#{self}: unable to add #{partName}, args=", args
    end
  end

end

##____________________________________________________________________________||
