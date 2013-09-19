# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

##____________________________________________________________________________||
def draw_empty_solid(entities, args)
  p args
  return draw_Box(entities, {"dx" => 1.cm, "dy" => 1.cm, "dz" => 1.cm})
end

##____________________________________________________________________________||
def draw_Torus_2pi(entities, args)

  def definePathToFollow(entities, args)
    center = [- args["outerRadius"] - 1.cm, 0, 0]
    norm = [1, 0, 0]
    norm.normalize!
    num_segments_per_pi = 36
    num_segments = num_segments_per_pi*2
    radius = args["torusRadius"]
    pathToFollow = entities.add_circle center, norm, radius, num_segments
    pathToFollow
  end

  def defineFace(entities, args)
    center = [0, args["torusRadius"], 0]
    norm = [0, 0, 1]
    norm.normalize!
    num_segments_per_pi = 18
    num_segments = num_segments_per_pi*2
    radius = args["outerRadius"]
    circle1 = entities.add_circle center, norm, radius, num_segments
    if args["innerRadius"] > 0
      radius = args["innerRadius"]
      circle2 = entities.add_circle center, norm, radius, num_segments
      face2 = entities.add_face circle2
    end
    face1 = entities.add_face circle1
    face2.erase! if face2
    face1
  end

  def reverseFacesIfInward(entities)
    def isInward(entities)
      unitZ = Geom::Vector3d.new 1, 0, 0
      zmax =  - 500000.m
      for e in entities
        next if e.typename != "Face"
        if zmax <= e.bounds.center[0]
          zmax = e.bounds.center[0]
          headFaceNomal = e.normal
        end
      end
      return headFaceNomal.dot(unitZ) < 0
    end
    def reverseFaces(entities)
      for e in entities
        next if e.typename != "Face"
        e.reverse!
      end
    end
    if isInward(entities)
      reverseFaces(entities)
    end
  end

  group = entities.add_group
  entities = group.entities
  pathToFollow = definePathToFollow entities, args
  face = defineFace entities, args
  face.followme pathToFollow
  pathToFollow.each { |e| e.erase! }
  reverseFacesIfInward(entities)
  group
end

##____________________________________________________________________________||
def draw_Torus_filled(entities, args)
  group = entities.add_group
  entities = group.entities

  args1 = args.clone
  torus1 = draw_Torus_filled_2pi(entities, args1)

  if 2*Math::PI - args["deltaPhi"] > 10**(-10)
    args2 = Hash.new
    args2["dz"] = args["outerRadius"]*2
    args2["startPhi"] = args["startPhi"]
    args2["deltaPhi"] = args["deltaPhi"]
    args2["rMax"] = args["torusRadius"] + args["outerRadius"]*2
    cylinder = draw_Cylinder entities, args2
    torus1 = cylinder.intersect(torus1)
  end

  torus1.explode

  group
end

##____________________________________________________________________________||
def draw_Torus(entities, args)
  group = entities.add_group
  entities = group.entities

  args1 = args.clone
  torus1 = draw_Torus_2pi(entities, args1)

  if 2*Math::PI - args["deltaPhi"] > 10**(-10)
    args2 = Hash.new
    args2["dz"] = args["outerRadius"]*2
    args2["startPhi"] = args["startPhi"]
    args2["deltaPhi"] = args["deltaPhi"]
    args2["rMax"] = args["torusRadius"] + args["outerRadius"]*2
    cylinder = draw_Cylinder entities, args2
    torus1 = cylinder.intersect(torus1)
  end

  torus1.explode


  group
end

##____________________________________________________________________________||
def draw_PseudoTrap(entities, args)
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
def draw_Trapezoid entities, args
  dz = args["dz"]
  alp1 = args["alp1"]
  bl1 = args["bl1"]
  tl1 = args["tl1"]
  h1 = args["h1"]
  alp2 = args["alp2"]
  bl2 = args["bl2"]
  tl2 = args["tl2"]
  h2 = args["h2"]
  phi = args.key?("phi") ? args["phi"] : 0
  theta = args.key?("theta") ? args["theta"] : 0

  # the center of the face at -dz 
  # -dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  centerDzm = Geom::Vector3d.new -dz, -dz*Math::tan(theta)*Math::cos(phi), -dz*Math::tan(theta)*Math::sin(phi)

  # the center of the side at -h1
  # -h1*(tan(alp1), 1, 0) -dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  centerH1m = Geom::Vector3d.new 0, -h1*Math::tan(alp1), -h1
  centerH1m += centerDzm

  # the two points of the side at -h1
  # ( bl1, 0, 0) + h1*(tan(alp1), -1, 0) -dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  # (-bl1, 0, 0) + h1*(tan(alp1), -1, 0) -dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  pointBl1m = Geom::Vector3d.new 0, -bl1, 0
  pointBl1p = Geom::Vector3d.new 0,  bl1, 0
  pointBl1m += centerH1m
  pointBl1p += centerH1m

  # the center of the side at +h1
  # -h1*(tan(alp1), -1, 0) -dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  centerH1p = Geom::Vector3d.new 0, h1*Math::tan(alp1), h1
  centerH1p += centerDzm

  # the two points of the side at +h1
  # ( tl1, 0, 0) + h1*(-tan(alp1), 1, 0) -dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  # (-tl1, 0, 0) + h1*(-tan(alp1), 1, 0) -dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  pointTl1m = Geom::Vector3d.new 0, -tl1, 0
  pointTl1p = Geom::Vector3d.new 0,  tl1, 0
  pointTl1m += centerH1p
  pointTl1p += centerH1p

  # the center of the face at +dz 
  # dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  centerDzp = Geom::Vector3d.new dz, dz*Math::tan(theta)*Math::cos(phi), dz*Math::tan(theta)*Math::sin(phi)

  # the center of the side at -h2
  # -h2*(tan(alp2), 1, 0) + dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  centerH2m = Geom::Vector3d.new 0, -h2*Math::tan(alp2), -h2
  centerH2m += centerDzp

  # the two points of the side at -h2
  # ( bl2, 0, 0) + h2*(tan(alp2), -1, 0) + dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  # (-bl2, 0, 0) + h2*(tan(alp2), -1, 0) + dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  pointBl2m = Geom::Vector3d.new 0, -bl2, 0
  pointBl2p = Geom::Vector3d.new 0,  bl2, 0
  pointBl2m += centerH2m
  pointBl2p += centerH2m


  # the center of the side at +h2
  # -h2*(tan(alp2), -1, 0) + dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  centerH2p = Geom::Vector3d.new 0, h2*Math::tan(alp2), h2
  centerH2p += centerDzp

  # the two points of the side at +h2
  # ( tl2, 0, 0) + h2*(-tan(alp2), 1, 0) + dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  # (-tl2, 0, 0) + h2*(-tan(alp2), 1, 0) + dz*(tan(theta)*cos(phi), tan(theta)*sin(phi), 1)
  pointTl2m = Geom::Vector3d.new 0, -tl2, 0
  pointTl2p = Geom::Vector3d.new 0,  tl2, 0
  pointTl2m += centerH2p
  pointTl2p += centerH2p

  group = entities.add_group
  entities = group.entities


  pointBl1m = Geom::Point3d.new pointBl1m.to_a
  pointBl1p = Geom::Point3d.new pointBl1p.to_a
  pointTl1m = Geom::Point3d.new pointTl1m.to_a
  pointTl1p = Geom::Point3d.new pointTl1p.to_a

  pointBl2m = Geom::Point3d.new pointBl2m.to_a
  pointBl2p = Geom::Point3d.new pointBl2p.to_a
  pointTl2m = Geom::Point3d.new pointTl2m.to_a
  pointTl2p = Geom::Point3d.new pointTl2p.to_a

  pointsList = Array.new
  pointsList << [pointBl1m, pointBl1p, pointTl1p, pointTl1m, pointBl1m]
  pointsList << [pointBl2m, pointBl2p, pointTl2p, pointTl2m, pointBl2m]
  pointsList << [pointBl1m, pointBl1p, pointBl2p, pointBl2m, pointBl1m]
  pointsList << [pointBl1p, pointTl1p, pointTl2p, pointBl2p, pointBl1p]
  pointsList << [pointTl1p, pointTl1m, pointTl2m, pointTl2p, pointTl1p]
  pointsList << [pointTl1m, pointTl2m, pointBl2m, pointBl1m, pointTl1m]

  pointsList.each do |points|
    face = entities.add_face points
  end

  def reverseFacesIfInward(entities)
    origin = Geom::Point3d.new 0, 0, 0
    for e in entities
      next if e.typename != "Face"
      e.reverse! if (e.normal.dot origin.vector_to(e.bounds.center)) < 0
    end
  end
  reverseFacesIfInward(entities)

  group
end

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
def draw_Tubs entities, args

  group = entities.add_group
  entities = group.entities

  args1 = args.clone
  args1.delete("rMin")
  cylinder1 = draw_Cylinder entities, args1
  if args["rMin"] > 0
    args2 = args.clone
    args2["rMax"] = args2["rMin"]
    args2.delete("rMin")
    cylinder2 = draw_Cylinder entities, args2
    cylinder1 = cylinder2.subtract(cylinder1)
  end
  cylinder1.explode

  group
end

##____________________________________________________________________________||
def draw_Polycone_2pi entities, args

  def definePathToFollow(entities, args)
    zmin = args["ZSection"].map { |i| i["z"] }.min
    center = [zmin - 1.cm, 0, 0]
    norm = [1, 0, 0]
    norm.normalize!

    num_segments_per_pi = 36
    num_segments = num_segments_per_pi*2

    radius = args["ZSection"].map { |i| [i["rMin"], i["rMax"]] }.flatten.delete_if { |l| l == 0 }.min*0.5

    pathToFollow = entities.add_circle center, norm, radius, num_segments
    pathToFollow
  end

  def defineFace(entities, args)
    edges = Array.new
    args["ZSection"].each do |sec|
      edge = Geom::Point3d.new(sec["z"], sec["rMax"], 0)
      edges << edge unless edges.include?(edge)
    end
    args["ZSection"].reverse.each do |sec|
      edge = Geom::Point3d.new(sec["z"], sec["rMin"], 0)
      edges << edge unless edges.include?(edge)
    end
    face = entities.add_face edges
    face
  end

  def reverseFacesIfInward(entities, args)
    def isInward(entities, args)
      unitZ = Geom::Vector3d.new 1, 0, 0
      zmax = args["ZSection"].map { |i| i["z"] }.min - 1.cm
      for e in entities
        next if e.typename != "Face"
        if zmax <= e.bounds.center[0]
          zmax = e.bounds.center[0]
          headFaceNomal = e.normal
        end
      end
      return headFaceNomal.dot(unitZ) < 0
    end
    def reverseFaces(entities)
      for e in entities
        next if e.typename != "Face"
        e.reverse!
      end
    end
    if isInward(entities, args)
      reverseFaces(entities)
    end
  end

  group = entities.add_group
  entities = group.entities
  pathToFollow = definePathToFollow entities, args
  face = defineFace entities, args
  face.followme pathToFollow
  pathToFollow.each { |e| e.erase! }
  reverseFacesIfInward(entities, args)

  group
end

##____________________________________________________________________________||
def draw_Polycone entities, args

  group = entities.add_group
  entities = group.entities

  args1 = args.clone
  polycone = draw_Polycone_2pi entities, args1

  if args["deltaPhi"] < 2*Math::PI
    args2 = Hash.new
    args2["dz"] = args["ZSection"].map {|e| e["z"].abs}.max
    args2["startPhi"] = args["startPhi"]
    args2["deltaPhi"] = args["deltaPhi"]
    args2["rMax"] = args["ZSection"].map {|e| e["rMax"] }.max*1.1
    cylinder = draw_Cylinder entities, args2
    polycone = cylinder.intersect(polycone)
  end

  polycone.explode

  group
end

##____________________________________________________________________________||
def draw_Cone entities, args
  args2 = Hash.new
  args2["startPhi"] = args["startPhi"]
  args2["deltaPhi"] = args["deltaPhi"]
  args2["ZSection"] = Array.new
  args2["ZSection"] << {'z' => -args['dz'], 'rMin' => args['rMin1'], 'rMax' => args['rMax1']}
  args2["ZSection"] << {'z' =>  args['dz'], 'rMin' => args['rMin2'], 'rMax' => args['rMax2']}
  draw_Polycone entities, args2
end

##____________________________________________________________________________||
def draw_Polyhedra_2pi entities, args
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

  def defineFace(entities, startPhi, deltaPhi, numSide, zs, rMaxs, rMins)
    zs = [zs, zs.reverse, zs[0]].flatten
    xs = [rMaxs, rMins.reverse, rMaxs[0]].flatten
    xs = xs.map { |x| x/Math::cos(deltaPhi/numSide/2)}
    ys = xs.map { |x| x*Math::sin(startPhi) }
    xs = xs.map { |x| x*Math::cos(startPhi) }
    edges = zs.zip(xs, ys)
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
  face = defineFace entities, startPhi, deltaPhi, numSide, zs, rMaxs, rMins
  face.followme pathToFollow
  pathToFollow.each { |e| e.erase! }
  reverseFacesIfInward(entities)

  group
end

##____________________________________________________________________________||
def draw_Polyhedra_lt2pi entities, args
  startPhi = args["startPhi"]
  deltaPhi = args["deltaPhi"]
  numSide = args["numSide"]
  zs = args["ZSection"].map {|z| z['z']}
  rMaxs = args["ZSection"].map {|z| z['rMax']}
  rMins = args["ZSection"].map {|z| z['rMin']}

  def defineFace(entities, startPhi, deltaPhi, numSide, zs, rMaxs, rMins)

    outerPoints00 = zs.zip(rMaxs, [0.0]*(zs.length)).map { |z, x, y| Geom::Point3d.new z, (x/Math::cos(deltaPhi/numSide/2)), y}
    innerPoints00 = zs.zip(rMins, [0.0]*(zs.length)).map { |z, x, y| Geom::Point3d.new z, (x/Math::cos(deltaPhi/numSide/2)), y}

    outerPoints0 = Array.new
    outerPoints00.each do |p|
      if outerPoints0.length > 1
        if (outerPoints0[-2][1] - p[1]).abs < 10**(-10) and (outerPoints0[-1][1] - p[1]).abs < 10**(-10)
          outerPoints0[-1] = p
          next
        end
      end
      outerPoints0 << p unless outerPoints0.include?(p)
    end
    innerPoints0 = Array.new
    innerPoints00.each do |p|
      if innerPoints0.length > 1
        if (innerPoints0[-2][1] - p[1]).abs < 10**(-10) and (innerPoints0[-1][1] - p[1]).abs < 10**(-10)
          innerPoints0[-1] = p
          next
        end
      end
      innerPoints0 << p unless innerPoints0.include?(p)
    end

    outerPointsList = Array.new
    innerPointsList = Array.new
    phis = (0..numSide).map { |i| startPhi + deltaPhi/numSide*i}
    phis.each do |phi|
      rotation = Geom::Transformation.rotation([0, 0, 0], [1, 0, 0], phi)
      outerPointsList << outerPoints0.map { |p| p.transform rotation }
      innerPointsList << innerPoints0.map { |p| p.transform rotation }
    end
    innerPointsList[0..-2].zip(innerPointsList[1..-1]).each do |points1, points2|
      points1[0..-2].zip(points1[1..-1], points2[1..-1], points2[0..-2]) do |ps|
        face = entities.add_face ps
      end
    end

    outerPointsList[0..-2].zip(outerPointsList[1..-1]).each do |points1, points2|
      points1[0..-2].zip(points1[1..-1], points2[1..-1], points2[0..-2]) do |ps|
        face = entities.add_face ps
      end
    end

    points = outerPointsList[0] + innerPointsList[0].reverse + [outerPointsList[0][0]]
    pointsForFace = Array.new
    points.each { |p| pointsForFace << p unless pointsForFace.include?(p) }
    face = entities.add_face pointsForFace

    points = outerPointsList[-1] + innerPointsList[-1].reverse + [outerPointsList[-1][0]]
    pointsForFace = Array.new
    points.each { |p| pointsForFace << p unless pointsForFace.include?(p) }
    face = entities.add_face pointsForFace

    points = outerPointsList.map { |ps| ps[0] } + innerPointsList.reverse.map { |ps| ps[0] }
    pointsForFace = Array.new
    points.each { |p| pointsForFace << p unless pointsForFace.include?(p) }
    face = entities.add_face pointsForFace unless pointsForFace.length < 4

    points = outerPointsList.map { |ps| ps[-1] } + innerPointsList.reverse.map { |ps| ps[-1] }
    pointsForFace = Array.new
    points.each { |p| pointsForFace << p unless pointsForFace.include?(p) }
    face = entities.add_face pointsForFace unless pointsForFace.length < 4

    return
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
  face = defineFace entities, startPhi, deltaPhi, numSide, zs, rMaxs, rMins
  reverseFacesIfInward(entities)

  group
end


##____________________________________________________________________________||
def draw_Polyhedra entities, args
  if (2*Math::PI - args["deltaPhi"]).abs < 10**(-10)
    return draw_Polyhedra_2pi(entities, args)
  else
    return draw_Polyhedra_lt2pi(entities, args)
  end
end

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
def draw_UnionSolid entities, args

  group = entities.add_group
  entities = group.entities

  origin = Geom::Point3d.new 0, 0, 0
  transform = Geom::Transformation.new origin

  solid0 = entities.add_instance args['rSolid'][0], transform
  solid1 = entities.add_instance args['rSolid'][1], transform

  transform = args['rRotation']*transform   if args.key?('rRotation')
  transform = args['Translation']*transform   if args.key?('Translation')


  solid1.transform! transform 

  solid = solid1.union(solid0)
  solid.explode

  group

end

##____________________________________________________________________________||
def draw_SubtractionSolid entities, args

  group = entities.add_group
  entities = group.entities

  origin = Geom::Point3d.new 0, 0, 0
  transform = Geom::Transformation.new origin

  solid0 = entities.add_instance args['rSolid'][0], transform
  solid1 = entities.add_instance args['rSolid'][1], transform

  transform = args['rRotation']*transform if args.key?('rRotation')
  transform = args['Translation']*transform  if args.key?('Translation')

  solid1.transform! transform 

  solid = solid1.subtract(solid0)
  solid.explode

  group

end

##____________________________________________________________________________||
