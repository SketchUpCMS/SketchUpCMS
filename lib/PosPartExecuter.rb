# Tai Sakuma <sakuma@fnal.gov>

##__________________________________________________________________||
class PosPartExecuter

  def initialize geometryManager
    @geometryManager = geometryManager
    @doneList = Set.new
  end

  def exec posPart, parent, child
    return if @doneList.include? posPart

    return unless parent
    return unless child

    if posPart.rotationName
      rotation = @geometryManager.rotationsManager.get(posPart.rotationName)
      puts "#{self}: not found: #{posPart.rotationName}" unless rotation
      return unless rotation
    else
      rotation = nil
    end

    parent.placeChild(child, posPart.translation, rotation)
    @doneList.add posPart
  end

end

##__________________________________________________________________||
