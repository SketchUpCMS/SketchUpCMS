# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
class Rotation
  attr_accessor :geometryManager
  attr_accessor :name
  attr_accessor :partName
  attr_accessor :sectionLabel
  attr_accessor :argsInDDL
  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} #{@name}>"
  end
  def initialize geometryManager, partName
    @geometryManager = geometryManager
    @partName = partName
  end
  def clear
    @transformation = nil
  end
  def transformation
    return @transformation if @transformation 
    @transformation = define_transformation_for_rotation_from_DDL(@argsInDDL)
    @transformation
  end
end

##____________________________________________________________________________||
def define_transformation_for_rotation_from_DDL(ddl)

  def convertArguments ddl
    nonnumericArgs = ['name']
    scalarNumericArgs = ['thetaX', 'phiX', 'thetaY', 'phiY', 'thetaZ', 'phiZ']
    knownArgs = nonnumericArgs + scalarNumericArgs

    ddl.keys.each do |k|
      p "#{self}: unknown argument #{k}" unless knownArgs.include?(k)
    end

    argsInSU = Hash.new

    nonnumericArgs.each do |name|
      next unless ddl.key?(name)
      argsInSU[name] = ddl[name]
    end

    scalarNumericArgs.each do |name|
      next unless ddl.key?(name)
      argsInSU[name] = stringToSUNumeric(ddl[name])
    end

    argsInSU
  end

  args = convertArguments(ddl)
  origin = Geom::Point3d.new 0, 0, 0
  xaxis = Geom::Vector3d.new Math::cos(args['thetaX']), Math::sin(args['thetaX'])*Math::cos(args['phiX']), Math::sin(args['thetaX'])*Math::sin(args['phiX'])
  yaxis = Geom::Vector3d.new Math::cos(args['thetaY']), Math::sin(args['thetaY'])*Math::cos(args['phiY']), Math::sin(args['thetaY'])*Math::sin(args['phiY'])
  zaxis = Geom::Vector3d.new Math::cos(args['thetaZ']), Math::sin(args['thetaZ'])*Math::cos(args['phiZ']), Math::sin(args['thetaZ'])*Math::sin(args['phiZ'])
  Geom::Transformation.axes origin, zaxis, xaxis, yaxis
end

##____________________________________________________________________________||
class RotationsManager
  attr_accessor :geometryManager
  attr_accessor :partsHash, :parts

  KnownPartNames = [:Rotation, :ReflectionRotation]

  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize
    @partsHash = Hash.new
    @parts = Array.new
  end
  def clear
    @parts.each {|p| p.clear if p}
  end
  def get(name)
    @partsHash.key?(name) ? @partsHash[name] : nil
  end
  def add part
    raise StandardError, "unknown part name \"#{partName}\"" unless KnownPartNames.include?(part.partName)
    @parts << part
    @partsHash[part.name] = part 
  end
end

##____________________________________________________________________________||
