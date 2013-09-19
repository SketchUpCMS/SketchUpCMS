# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
def draw_Trd1(entities, args)
  def defineFace entities, args
    norm = Geom::Vector3d.new 0, 0, 1

    p1 = Geom::Point3d.new( args["dz"],  args["dx2"], -args["dy1"])
    p2 = Geom::Point3d.new( args["dz"], -args["dx2"], -args["dy1"])
    p3 = Geom::Point3d.new(-args["dz"], -args["dx1"], -args["dy1"])
    p4 = Geom::Point3d.new(-args["dz"],  args["dx1"], -args["dy1"])
    face = entities.add_face [p1, p2, p3, p4]
    face.reverse! if (face.normal.dot norm) < 0
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
  face.pushpull(2*args["dy1"], true)
  reverseFacesIfInward(entities)

  group
end

##____________________________________________________________________________||
