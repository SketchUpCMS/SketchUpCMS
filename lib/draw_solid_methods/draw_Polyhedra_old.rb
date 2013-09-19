# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
def draw_Polyhedra_old entities, args
  startPhi = args["startPhi"]
  deltaPhi = args["deltaPhi"]
  numSide = args["numSide"]
  zs = args["ZSection"].map {|z| z['z']}
  rMaxs = args["ZSection"].map {|z| z['rMax']}
  rMins = args["ZSection"].map {|z| z['rMin']}

  def definePathToFollow(entities, startPhi, deltaPhi, numSide, zs, rMaxs, rMins)
    radius =  ([rMins, rMaxs].flatten.delete_if { |l| l == 0 }).min*0.5
    phis = (0..numSide).map { |i| startPhi + deltaPhi/numSide*i}
    points = phis.map { |phi| Geom::Point3d.new(zs[0]*1.1, radius*Math::cos(phi), radius*Math::sin(phi))}
    points.pop if deltaPhi >= 2*Math::PI
    pathToFollow = entities.add_edges points
    pathToFollow << entities.add_line(points[-1], points[0]) if deltaPhi >= 2*Math::PI
    pathToFollow
  end

  def defineFace(entities, startPhi, deltaPhi, zs, rMaxs, rMins)
    zs = [zs, zs.reverse, zs[0]].flatten
    xs = [rMaxs, rMins.reverse, rMaxs[0]].flatten
    ys = xs.map { |x| x*Math::sin(startPhi) }
    xs = xs.map { |x| x*Math::cos(startPhi) }
    edges = zs.zip(xs, ys)
    # edges.inject([]) {|ee, ff| ee << ff unless ee.last == ff; ee}
    edges.uniq!
    face = entities.add_face edges
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
  pathToFollow = definePathToFollow entities, startPhi, deltaPhi, numSide, zs, rMaxs, rMins
  face = defineFace entities, startPhi, deltaPhi, zs, rMaxs, rMins
  # face.followme pathToFollow
  # pathToFollow.each { |e| e.erase! }
  reverseFacesIfInward(entities)

  group
end

##____________________________________________________________________________||
