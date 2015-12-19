# Tai Sakuma <sakuma@fnal.gov>

require "stringToSUNumeric"

##____________________________________________________________________________||
class Rotation
  attr_accessor :geometryManager
  attr_accessor :name
  attr_accessor :partName
  attr_accessor :argsInDDL
  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} #{@name}>"
  end
  def initialize geometryManager, partName
    @geometryManager = geometryManager
    @partName = partName
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
