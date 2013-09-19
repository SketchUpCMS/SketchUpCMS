# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
def draw_Box entities, args

  dx = args["dx"]
  dy = args["dy"]
  dz = args["dz"]

  def defineFace(entities, dx, dy, dz)
    norm = Geom::Vector3d.new 1, 0, 0

    p1 = Geom::Point3d.new(-dz,  dx, dy)
    p2 = Geom::Point3d.new(-dz, -dx, dy)
    p3 = Geom::Point3d.new(-dz, -dx, -dy)
    p4 = Geom::Point3d.new(-dz,  dx, -dy)
    edges = entities.add_edges [p1, p2, p3, p4]
    edges << entities.add_line(edges[0].start, edges[-1].end)
    face = entities.add_face edges
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
  face = defineFace entities, dx, dy, dz
  face.pushpull(2*dz, true)
  reverseFacesIfInward(entities)

  group
end

##____________________________________________________________________________||
