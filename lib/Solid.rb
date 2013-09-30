# Tai Sakuma <sakuma@fnal.gov>

require 'SolidDefiner'

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
  def definition
    return @definition if (@definition and (not @definition.deleted?))
    @definition = defineSolid()
    @definition
  end

  def defineSolid
    begin
      definer = SolidDefiner.new(@geometryManager)
      return definer.define(@partName, @name, @argsInDDL)
    rescue Exception => e
      $stderr.write e.message + "\n"
      $stderr.write self.class.name + ": Unable to defineSolid: #{@name}\n"
      return nil
    end
  end

end

##____________________________________________________________________________||
