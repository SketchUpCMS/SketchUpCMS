# Tai Sakuma <sakuma@fnal.gov>
require 'EntityDisplayer'

##____________________________________________________________________________||
class EntityDisplayer
  def inspect
    "#<" + self.class.name + ":0x" + self.object_id.to_s(16) + ">"
  end
  def initialize layerName, z, x, y
    @z0, @x0, @y0  = z, x, y
    @z, @x, @y  = @z0, @x0, @y0 
    model = Sketchup.active_model
    @layer = model.layers.add(model.layers.unique_name(layerName))
  end
  def clear
    @z, @x, @y  = @z0, @x0, @y0 
  end
  def display instance
    instance.layer = @layer
    x = instance.bounds.height
    @x += x
    vector = Geom::Vector3d.new(@z, @x, @y + instance.bounds.depth/2*1.05)
    @x += x
    transformation = Geom::Transformation.translation vector
    instance.transform! transformation
  end
end

##____________________________________________________________________________||
