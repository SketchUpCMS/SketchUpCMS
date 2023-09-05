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

  
  def makeSideFaces(a, b, entities)

    vertices = Array.new

    (0..a.length-1).each do |ai|

      if ai < a.length-1
        vertices = [a[ai], b[ai], b[ai+1], a[ai+1]]
      else
        vertices = [a[ai], b[ai], b[0], a[0]]
      end

      face = entities.add_face vertices
      
    end
  end

  
  def connectFaces(entities, args)

    zpoints = Array.new
    
    args["ZXYSection"].each do |zxy|

      points = Array.new
      
      args["XYPoint"].each do |xy|

        x = xy["x"]*zxy["scale"] + zxy["x"]
        y = xy["y"]*zxy["scale"] + zxy["y"]
        
        point = Geom::Point3d.new(x, y, zxy["z"])        
        points << point
      end

      zpoints << points
      
    end

    (0..zpoints.length-2).each do |p|
      makeSideFaces(zpoints[p], zpoints[p+1], entities)
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
  connectFaces entities, args
  
  reverseFacesIfInward(entities)

  group
  
end
##____________________________________________________________________________||

  
