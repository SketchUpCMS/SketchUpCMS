# Thomas McCauley <thomas.mccauley@cern.ch>

##____________________________________________________________________________||
def draw_ExtrudedPolygon entities, args

  zxs = args["ZXYSection"].map {|x| x['x']}
  zys = args["ZXYSection"].map {|x| x['y']}
  zscales = args["ZXYSection"].map {|x| x['scale']}

  def defineFace(entities, args)
    points = Array.new

    args["XYPoint"].each do |xy|
      point = Geom::Point3d.new(xy["x"], xy["y"], 0)
      points << point
    end

    face = entities.add_face points
    face
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
  face = defineFace entities, args

  puts "Face:"
  p face
  
  #reverseFacesIfInward(entities)

  group
  
end
##____________________________________________________________________________||

  
