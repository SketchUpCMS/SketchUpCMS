# Tai Sakuma <sakuma@fnal.gov>
require 'EntityDisplayer'

##____________________________________________________________________________||
class UnknownSolidDefiner

  def initialize geometryManager
    @geometryManager = geometryManager
  end

  def define(partName, name, ddl)
    args = convertArguments(ddl)
    entities = Sketchup.active_model.entities
    solid = drawMethod(partName).call(entities, args)
    instance = solid.to_component
    definition = instance.definition
    definition.name = "solid_" + name.to_s
    $geometryManager.solidsManager.moveInstanceAway(instance)
    return definition
  end

  def drawMethod partName
    method("draw_empty_solid")
  end

  def convertArguments argsInDDL
    Hash.new
  end

end

##____________________________________________________________________________||
class BasicSolidDefiner

  def initialize geometryManager
    @geometryManager = geometryManager
  end

  def define(partName, name, ddl)
    args = convertArguments(ddl)
    entities = Sketchup.active_model.entities
    solid = drawMethod(partName).call(entities, args)
    instance = solid.to_component
    definition = instance.definition
    definition.name = "solid_" + name.to_s
    $geometryManager.solidsManager.moveInstanceAway(instance)
    return definition

  end

  def drawMethod partName
    method("draw_#{partName}")
  end

  def convertArguments argsInDDL
    nonnumericArgs = ['name']
    scalarNumericArgs = Array.new
    scalarNumericArgs += ['numSide', 'startPhi', 'deltaPhi', 'dx', 'dy', 'dz', 'rMax', 'rMin', 'rMax1', 'rMin1', 'rMax2', 'rMin2', 'alp1', 'bl1', 'tl1', 'h1', 'alp2', 'bl2', 'tl2', 'h2', 'phi', 'theta']
    scalarNumericArgs += ["radius", "atMinusZ", "dy1", "dx1", "dy2", "dx2"]
    scalarNumericArgs += ["innerRadius", "outerRadius", "torusRadius", "startPhi", "deltaPhi"]
    vectorArgs = ['ZSection']
    
    knownArgs = nonnumericArgs + scalarNumericArgs + vectorArgs

    argsInDDL.keys.each do |k|
      $stderr.write self.class.name + ": Unknown argument: \"#{k}\"\n" unless knownArgs.include?(k)
    end
    
    argsInSU = Hash.new

    nonnumericArgs.each do |name|
      next unless argsInDDL.key?(name)
      argsInSU[name] = argsInDDL[name]
    end

    scalarNumericArgs.each do |name|
      next unless argsInDDL.key?(name)
      argsInSU[name] = stringToSUNumeric(argsInDDL[name])
    end

    knownNamesForZSection = ['z', 'rMin', 'rMax']
    if argsInDDL.key?('ZSection')
      zSectionsInSU = Array.new
      argsInDDL['ZSection'].each do |zsecInDDL|
        zsecInSU = Hash.new
        zsecInDDL.keys.each do |k|
          p "#{self}: unknown argument #{k}" unless knownNamesForZSection.include?(k)
        end
        knownNamesForZSection.each do |k|
          zsecInSU[k] = stringToSUNumeric(zsecInDDL[k])
        end
        zSectionsInSU << zsecInSU
      end
      argsInSU['ZSection'] = zSectionsInSU
    end

    argsInSU
  end

end

##____________________________________________________________________________||
class CompoundSolidDefiner

  def initialize geometryManager
    @geometryManager = geometryManager
  end

  def define(partName, name, ddl, s)

    verifyDDL(ddl)

    definition1 =  definition1(ddl)
    definition2 =  definition2(ddl)
    translation = translation(ddl)
    rotation = rotation(ddl)

    transform2 = translation*rotation
    solid = doSolidTool(partName, definition1, definition2, transform2)
    instance = solid.to_component
    definition = instance.definition
    definition.name = "solid_" + name.to_s
    $geometryManager.solidsManager.moveInstanceAway(instance)
    return definition
  end

  def definition1 ddl
    name = ddl['rSolid'][0]['name'].to_sym
    solid = @geometryManager.solidsManager.get(name)
    solid.definition
  end

  def definition2 ddl
    name = ddl['rSolid'][1]['name'].to_sym
    solid = @geometryManager.solidsManager.get(name)
    solid.definition
  end

  def translation ddl
    if ddl.has_key?('Translation')
      x = stringToSUNumeric(ddl['Translation'][0]['x'])
      y = stringToSUNumeric(ddl['Translation'][0]['y'])
      z = stringToSUNumeric(ddl['Translation'][0]['z'])
      vector = Geom::Vector3d.new z, x, y
      translation = Geom::Transformation.translation vector
    else
      translation = Geom::Transformation.new
    end
    translation
  end

  def rotation ddl
    if ddl.key?('rRotation')
      name = ddl['rRotation'][0]['name'].to_sym
      rotation =  @geometryManager.rotationsManager.get(name).transformation
    else
      rotation =  Geom::Transformation.new
    end
    rotation
  end

  def verifyDDL ddl
    knownArgs = ['name', 'rSolid', 'rRotation', 'Translation']

    ddl.keys.each do |k|
      next if knownArgs.include?(k)
      $stderr.write self.class.name + ": Unknown argument: \"#{k}\"\n"
    end

    if ddl['rSolid'].length != 2
      $stderr.write self.class.name + ": Length is not 2\n"
    end

    if ddl.has_key?('rRotation') and ddl['rRotation'].length != 1
      $stderr.write self.class.name + ": Length is not 1\n"
    end

    if ddl.has_key?('Translation') and ddl['Translation'].length != 1
      $stderr.write self.class.name + ": Length is not 1\n"
    end

  end

  def doSolidTool partName, definition1, definition2, transform2

    transform1 = Geom::Transformation.new

    entities = Sketchup.active_model.entities

    group = entities.add_group
    entities = group.entities

    instance1 = entities.add_instance definition1, transform1
    instance2 = entities.add_instance definition2, transform2

    if partName == :UnionSolid
      instance = instance2.union(instance1)
    elsif partName == :SubtractionSolid
      instance = instance2.subtract(instance1)
    else
      $stderr.write self.class.name + ": Unknown partName: #{partName}\n"
    end

    instance.explode

    group
  end

end


##____________________________________________________________________________||
class Solid
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
    @definition = nil
  end
  def definition
    return @definition if (@definition and (not @definition.deleted?))
    @definition = defineSolid()
    @definition
  end
end

##____________________________________________________________________________||
class BasicSolid < Solid
  attr_writer :argsInSU
  def clear
    super
    @argsInSU = nil if @argsInDDL
  end
  def argsInSU
    return @argsInSU if @argsInSU
    @argsInSU = convertArguments(@argsInDDL)
    @argsInSU
  end
  def defineSolid
    begin
      definer = BasicSolidDefiner.new(@geometryManager)
      return definer.define(@partName, @name, @argsInDDL)
    rescue Exception => e
      puts e.message
      p "#{self}: unable to defineSolid: #{@name}"
      return nil
    end
  end
end

##____________________________________________________________________________||
class CompoundSolid < Solid
  def clear
    super
  end

  def defineSolid
    begin
      definer = CompoundSolidDefiner.new(@geometryManager)
      return definer.define(@partName, @name, @argsInDDL, self)
    rescue Exception => e
      puts e.message
      p "#{self}: unable to defineSolid: #{@name}"
      return nil
    end
  end

end

##____________________________________________________________________________||
class UnknownSolid < Solid
  def defineSolid
    definer = UnknownSolidDefiner.new(@geometryManager)
    return definer.define(@partName, @name, @argsInDDL)
    begin
      definer = UnknownSolidDefiner.new(@geometryManager)
      return definer.define(@partName, @name, @argsInDDL)
    rescue Exception => e
      puts e.message
      p "#{self}: unable to defineSolid: #{@name}"
      return nil
    end
  end
end

##____________________________________________________________________________||
