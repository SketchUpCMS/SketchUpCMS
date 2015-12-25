# Tai Sakuma <sakuma@fnal.gov>

##__________________________________________________________________||
class PosPart
  attr_accessor :partName
  attr_accessor :parentName, :childName
  attr_accessor :copyNumber
  attr_accessor :rotationName
  attr_accessor :translation
  attr_accessor :argsInDDL

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

  def initialize partName
    @partName = partName
  end

end

##__________________________________________________________________||
