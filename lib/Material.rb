# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
class Material
  attr_accessor :geometryManager
  attr_accessor :name
  attr_accessor :partName
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
    m
  end
end

##____________________________________________________________________________||
