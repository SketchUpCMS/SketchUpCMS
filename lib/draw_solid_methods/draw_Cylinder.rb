# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
def draw_Cylinder entities, args

  dz = args["dz"]
  startPhi = args["startPhi"]
  deltaPhi = args["deltaPhi"]
  rMax = args["rMax"]

  def defineFace(entities, dz, startPhi, deltaPhi, rMax)
    center = [-dz, 0, 0]
    norm = [1, 0, 0]
    norm.normalize!

    num_segments_per_pi = 36
    num_segments = num_segments_per_pi/Math::PI*deltaPhi

    if deltaPhi >= 2*Math::PI
      circle = entities.add_circle center, norm, rMax, num_segments
      face = entities.add_face circle
    elsif (deltaPhi - Math::PI).abs < 10**(-10)
      xaxis = Geom::Vector3d.new 0, 1, 0
      start_angle = startPhi
      end_angle = startPhi + deltaPhi
      arc = entities.add_arc center, xaxis, norm, rMax, start_angle, end_angle, num_segments
      arc << entities.add_line(arc[-1].end, arc[0].start)
      face = entities.add_face arc
    else
      xaxis = Geom::Vector3d.new 0, 1, 0
      start_angle = startPhi
      end_angle = startPhi + deltaPhi
      arc = entities.add_arc center, xaxis, norm, rMax, start_angle, end_angle, num_segments
      arc << entities.add_line(arc[-1].end, center)
      arc << entities.add_line(center, arc[0].start)
      face = entities.add_face arc
    end

    face
  end

  def reverseFacesIfInward(group, entities)
    for e in entities
      next if e.typename != "Face"
      origin = Geom::Point3d.new 0, 0, 0
      center = group.bounds.center

      normal = e.normal
      normal.length = normal.length*10
      entities.add_line(e.bounds.center, e.bounds.center + normal)

      e.reverse! if (e.normal.dot center.vector_to(e.bounds.center)) < 0
    end
  end

  group = entities.add_group
  entities = group.entities
  face = defineFace entities, dz, startPhi, deltaPhi, rMax
  face.pushpull(2*dz, true)
  face.reverse!
  ## reverseFacesIfInward(group, entities)

  group
end

##____________________________________________________________________________||
