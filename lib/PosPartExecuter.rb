# Tai Sakuma <sakuma@fnal.gov>

##__________________________________________________________________||
class PosPartExecuter

  def initialize
    @doneList = Set.new
  end

  def exec posPart
    return if @doneList.include? posPart
    child = posPart.child()
    return unless child
    posPart.parent().placeChild(child, posPart.translation(), posPart.rotation())
    @doneList.add posPart
  end

end

##__________________________________________________________________||
