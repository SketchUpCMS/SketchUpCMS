# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
class Rotation
  attr_accessor :geometryManager
  attr_accessor :name
  attr_accessor :partName
  attr_accessor :sectionLabel
  attr_accessor :argsInDDL
  attr_writer :argsInSU
  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} #{@name}>"
  end
  def initialize geometryManager, partName, name
    @geometryManager = geometryManager
    @partName = partName
    @name = name
  end
  def clear
    @transformation = nil
    @argsInSU = nil if @argsInDDL
  end
  def transformation
    return @transformation if @transformation 
    @transformation = defineTransformation()
    @transformation
  end
  def argsInSU
    return @argsInSU if @argsInSU
    @argsInSU = convertArguments(@argsInDDL)
    @argsInSU
  end
  def convertArguments argsInDDL
    nonnumericArgs = ['name']
    scalarNumericArgs = ['thetaX', 'phiX', 'thetaY', 'phiY', 'thetaZ', 'phiZ']
    knownArgs = nonnumericArgs + scalarNumericArgs

    argsInDDL.keys.each do |k|
      p "#{self}: unknown argument #{k}" unless knownArgs.include?(k)
    end

    argsInSU = Hash.new

    nonnumericArgs.each do |name|
      next unless argsInDDL.key?(name)
      argsInSU[name] = argsInDDL[name]
    end

    scalarNumericArgs.each do |name|
      next unless argsInDDL.key?(name)
      argsInSU[name] = @geometryManager.constantsManager.inSU(argsInDDL[name])
    end

    argsInSU
  end
  def defineTransformation
    args = argsInSU()
    origin = Geom::Point3d.new 0, 0, 0
    xaxis = Geom::Vector3d.new Math::cos(args['thetaX']), Math::sin(args['thetaX'])*Math::cos(args['phiX']), Math::sin(args['thetaX'])*Math::sin(args['phiX'])
    yaxis = Geom::Vector3d.new Math::cos(args['thetaY']), Math::sin(args['thetaY'])*Math::cos(args['phiY']), Math::sin(args['thetaY'])*Math::sin(args['phiY'])
    zaxis = Geom::Vector3d.new Math::cos(args['thetaZ']), Math::sin(args['thetaZ'])*Math::cos(args['phiZ']), Math::sin(args['thetaZ'])*Math::sin(args['phiZ'])
    Geom::Transformation.axes origin, zaxis, xaxis, yaxis
  end
end

##____________________________________________________________________________||
class RotationsManager
  attr_accessor :geometryManager
  attr_accessor :inDDLInOrderOfAddition
  attr_accessor :partsHash, :partsInOrderOfAddition
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHash = Hash.new
    @partsInOrderOfAddition = Array.new
    @inDDLInOrderOfAddition = Array.new
  end
  def clear
    @partsInOrderOfAddition.each {|p| p.clear if p}
  end
  def addInDDL partName, sectionLabel, args
    inDDL = {:partName => partName, :sectionLabel => sectionLabel, :args => args}
    @inDDLInOrderOfAddition << inDDL
    addToPartsHash inDDL
  end
  def buildPartsHash
    @partsInOrderOfAddition = Array.new
    @partsHash = Hash.new
    @inDDLInOrderOfAddition.each {|inDDL| addToPartsHash inDDL}
  end
  def addToPartsHash inDDL
    name = inDDL[:args]['name'].to_sym
    part = buildPart(inDDL)
    addPart name, part 
  end
  def buildPart inDDL
    name = inDDL[:args]['name'].to_sym
    part = Rotation.new @geometryManager, inDDL[:partName], name
    part.sectionLabel = inDDL[:sectionLabel]
    part.argsInDDL = inDDL[:args]
    part
  end
  def addPart name, part
    @partsInOrderOfAddition << part
    @partsHash[name] = part 
  end
  def get(name)
    return nil unless @partsHash.key?(name)
    @partsHash[name]
  end

  def getInSU name
  end
end

##____________________________________________________________________________||
