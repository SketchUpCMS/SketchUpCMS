# Tai Sakuma <sakuma@fnal.gov>

##__________________________________________________________________||
class LogicalPart
  attr_accessor :name
  attr_accessor :partName
  attr_accessor :solidName
  attr_accessor :materialName
  attr_accessor :argsInDDL

  # example,
  #   name = :"tracker:Tracker"
  #   partName = :LogicalPart
  #   solidName = :"tracker:Tracker"
  #   materialName = :"materials:Air"
  #   argsInDDL = {
  #     "rMaterial"=>[{"name"=>"materials:Air"}],
  #     "name"=>"tracker:Tracker",
  #     "rSolid"=>[{"name"=>"tracker:Tracker"}]}

  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} #{@name}>"
  end

  def initialize partName
    @partName = partName
  end

end

##__________________________________________________________________||
