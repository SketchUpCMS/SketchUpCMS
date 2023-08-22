# Thomas McCauley <thomas.mccauley@cern.ch>

##____________________________________________________________________________||
def draw_ExtrudedPolygon entities, args

  def defineFaces(entities, args)

    args["ZXYSection"].each do |zxy|

      points = Array.new
      
      args["XYPoint"].each do |xy|

        x = xy["x"]*zxy["scale"] + zxy["x"]
        y = xy["y"]*zxy["scale"] + zxy["y"]
        
        point = Geom::Point3d.new(x, y, zxy["z"])        
        points << point
      end
      
      face = entities.add_face points
      
    end

  end
  
  def reverseFacesIfInward(entities)
    for e in entities
      next if e.typename != "Face"
      origin = Geom::Point3d.new 0, 0, 0
      e.reverse! if (e.normal.dot origin.vector_to(e.bounds.center)) < 0
    end
  end

  group = entities.add_group
  entities = group.entities
  defineFaces entities, args
  
  #reverseFacesIfInward(entities)

  group
  
end
##____________________________________________________________________________||

  
