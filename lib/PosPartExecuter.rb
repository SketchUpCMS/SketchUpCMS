# Tai Sakuma <sakuma@fnal.gov>

##__________________________________________________________________||
class PosPartExecuter

  def initialize geometryManager
    @geometryManager = geometryManager
    @doneList = Set.new
  end

  def exec posPart, parentName, childName
    return if @doneList.include? posPart

    child = @geometryManager.logicalPartsManager.get(childName)
    puts "#{self}: not found: #{posPart.childName}" unless child
    return unless child

    parent = @geometryManager.logicalPartsManager.get(parentName)
    puts "#{self}: not found: #{posPart.parentName}" unless parent
    return unless parent

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
