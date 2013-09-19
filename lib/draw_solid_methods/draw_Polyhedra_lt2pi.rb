# Tai Sakuma <sakuma@fnal.gov>

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
