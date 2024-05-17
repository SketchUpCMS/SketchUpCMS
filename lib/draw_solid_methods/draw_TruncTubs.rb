# Thomas McCauley <thomas.mccauley@cern.ch>

##_______________________________________________________||
def draw_TruncTubs entities, args
  
  group = entities.add_group
  entities = group.entities
  
  zHalf = args["zHalf"]
  rMin = args["rMin"]
  rMax = args["rMax"]
  startPhi = args["startPhi"]
  deltaPhi = args["deltaPhi"]
  cutAtStart = args["cutAtStart"]
  cutAtDelta = args["cutAtDelta"]
  cutInside = args["cutInside"]

  r = cutAtStart
  s = cutAtDelta

  # Implement a la Shapes.cpp in DD4hep:
  # Draw the required Tubs and then a Box
  # which cuts into the Tubs at the required spot.
  # The required spot depends on whether or not
  # we want a cut inside or outside.
  # Then subtract the Box from the Tubs.
  
  cath = r - s*Math.cos(deltaPhi)
  hypo = Math.sqrt(r*r + s*s - 2*r*s*Math.cos(deltaPhi))
  cos_alpha = cath / hypo
  alpha = Math.acos(cos_alpha)
  sin_alpha = Math.sin(alpha.abs)

  boxX = rMax + rMax/sin_alpha
  boxY = rMax
  boxZ = zHalf

  if ! cutInside
    xBox = r + boxY/sin_alpha 
  else
    xBox = r - boxY/sin_alpha
  end
  
  box = draw_Box entities, {"dx" => boxX, "dy" => boxY, "dz" => boxZ }

  # The axes in SketchUp are oriented differently than assumed above
  # so we translate along Y rather than X and
  # rotate about X rather than Z
  
  translation = Geom::Transformation.translation(Geom::Vector3d.new(0, xBox, 0))
  rotation = Geom::Transformation.rotation([0,0,0], [1,0,0], -alpha)

  box.transform! rotation
  box.transform! translation
  
  tubs = draw_Tubs entities, {"dz" => zHalf, "startPhi" => startPhi, "deltaPhi" => deltaPhi, "rMin" => rMin, "rMax" => rMax}
  
  trunctubs = box.subtract(tubs)
  trunctubs.explode

  group

end
