# Tai Sakuma <sakuma@fnal.gov>

##__________________________________________________________________||
class PosPart
  attr_accessor :geometryManager
  attr_accessor :partName
  attr_accessor :parentName, :childName
  attr_accessor :copyNumber
  attr_accessor :rotationName
  attr_accessor :translation
  attr_accessor :argsInDDL
  attr_accessor :done

  # example
  #   partName = :PosPart
  #   parentName = :"tobmodule0:TOBModule0"
  #   childName = :"tobrod1l:TOBRodCentral1L"
  #   copyNumber = 4
  #   rotationName = :"name"=>"tobrodpar:180X"
  #   translation = {"z"=>"77.086*mm", "y"=>"-5.425*mm", "x"=>"0.00*mm"}
  #   argsInDDL = {
  #     "copyNumber"=>"4",
  #     "rChild"=>[{"name"=>"tobmodule0:TOBModule0"}],
  #     "rParent"=>[{"name"=>"tobrod1l:TOBRodCentral1L"}],
  #     "Translation"=>[{"z"=>"77.086*mm", "y"=>"-5.425*mm", "x"=>"0.00*mm"}],
  #     "rRotation"=>[{"name"=>"tobrodpar:180X"}]}

  def inspect
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} parent=#{parentName()} child=#{childName()} copyNumber=#{copyNumber()}}>"
  end

  def initialize geometryManager, partName
    @geometryManager = geometryManager
    @partName = partName
    @done = false
  end

  def parent
    return @parent if @parent
    @parent = @geometryManager.logicalPartsManager.get(@parentName)
    p "#{self}: not found: #{@parentName}" unless @parent
    @parent
  end

  def child
    return @child if @child
    @child = @geometryManager.logicalPartsManager.get(@childName)
    p "#{self}: not found: #{@childName}" unless @child
    @child
  end

  def rotation
    return @rotation if @rotation
    if @rotationName
      @rotation = @geometryManager.rotationsManager.get(@rotationName)
      p "#{self}: not found: #{@rotationName}" unless @rotation
    else
      @rotation = nil
    end
    @rotation
  end
end

##__________________________________________________________________||
