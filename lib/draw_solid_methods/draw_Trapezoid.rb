# Tai Sakuma <sakuma@fnal.gov>

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
