# Tai Sakuma <sakuma@fnal.gov>
require 'EntityDisplayer'

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
      args = argsInSU()
      entities = Sketchup.active_model.entities
      solid = drawMethod().call(entities, args)
      instance = solid.to_component
      definition = instance.definition
      definition.name = "solid_" + @name.to_s
      $geometryManager.solidsManager.moveInstanceAway(instance)
      return definition
    rescue Exception => e
      puts e.message
      p "#{self}: unable to defineSolid: #{@name}"
      return nil
    end
  end
  def drawMethod 
    method("draw_#{@partName}")
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
      p "#{self}: unknown argument #{k}" unless knownArgs.include?(k)
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
class CompoundSolid < Solid
  attr_accessor :solid1, :solid2, :rotation, :translation
  attr_writer :argsInSU
  def clear
    super
    @solid1 = nil if @argsInSU
    @solid2 = nil if @argsInSU
    @rotation = nil if @argsInSU
    @translation = nil if @argsInSU
    @argsInSU = nil if @argsInDDL
  end
  def argsInSU
    return @argsInSU if @argsInSU
    @argsInSU = convertArguments(@argsInDDL)
    @argsInSU
  end
  def solid1
    return @solid1 if @solid1
    name = argsInSU()['rSolid'][0]
    @solid1 = $geometryManager.solidsManager.get(name)
    @solid1
  end
  def solid2
    return @solid2 if @solid2
    name = argsInSU()['rSolid'][1]
    @solid2 = $geometryManager.solidsManager.get(name)
    @solid2
  end
  def rotation
    return @rotation if @rotation
    if argsInSU().key?('rRotation')
      name = argsInSU()['rRotation']
      @rotation =  @geometryManager.rotationsManager.get(name).transformation
    else
      @rotation =  Geom::Transformation.new
    end
    @rotation
  end
  def translation
    return @translation if @translation
    if argsInSU().key?('Translation')
      tr = argsInSU()['Translation']
      vector = Geom::Vector3d.new tr['z'], tr['x'], tr['y']
      @translation = Geom::Transformation.translation vector
    else
      @translation =  Geom::Transformation.new
    end
    @translation
  end
  def defineSolid
    begin
      args = argsInSU()
      solid = doSolidTool(args)
      instance = solid.to_component
      definition = instance.definition
      definition.name = "solid_" + @name.to_s
      $geometryManager.solidsManager.moveInstanceAway(instance)
      return definition
    rescue Exception => e
      puts e.message
      p "#{self}: unable to defineSolid: #{@name}"
      return nil
    end
  end
  def doSolidTool args

    definition1 =  solid1().definition
    definition2 =  solid2().definition

    transform1 = Geom::Transformation.new
    transform2 = translation()*rotation()

    entities = Sketchup.active_model.entities

    group = entities.add_group
    entities = group.entities

    instance1 = entities.add_instance definition1, transform1
    instance2 = entities.add_instance definition2, transform2

    if @partName == :UnionSolid
      instance = instance2.union(instance1)
    elsif @partName == :SubtractionSolid
      instance = instance2.subtract(instance1)
    else
      p "#{self}: unknown @partName: #{@partName}"
    end

    instance.explode

    group
  end
  def convertArguments args
    ret = Hash.new
    args.each do |name, value|
      if name == 'name'
        next
      elsif name == 'rSolid'
        raise StandardError, "length should be 2" unless value.length == 2
        ret[name] = Array.new
        ret[name] << value[0]['name'].to_sym
        ret[name] << value[1]['name'].to_sym
      elsif name == 'rRotation'
        raise StandardError, "length should be 1" unless value.length == 1
        ret[name] = value[0]['name'].to_sym
      elsif name == 'Translation'
        raise StandardError, "length should be 1" unless value.length == 1
        x = stringToSUNumeric(value[0]['x'])
        y = stringToSUNumeric(value[0]['y'])
        z = stringToSUNumeric(value[0]['z'])
        ret[name] = {'x' => x, 'y' => y, 'z' => z}
      else
        p 'unknown argument ', name
      end
    end
    ret
  end
end

##____________________________________________________________________________||
class UnknownSolid < Solid
  def defineSolid
    begin
      args = Hash.new
      entities = Sketchup.active_model.entities
      solid = drawMethod().call(entities, args)
      instance = solid.to_component
      definition = instance.definition
      definition.name = "solid_" + @name.to_s
      $geometryManager.solidsManager.moveInstanceAway(instance)
      return definition
    rescue Exception => e
      puts e.message
      p "#{self}: unable to defineSolid: #{@name}"
      return nil
    end
  end
  def drawMethod 
    method("draw_empty_solid")
  end
end

##____________________________________________________________________________||
