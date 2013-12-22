# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

##____________________________________________________________________________||
def cmsmain

  Sketchup.active_model.start_operation("modify HCAL module", true)

  definitions = Sketchup.active_model.definitions
  
  lp_HBModule = definitions.select { |e| e.name.match(/lp_hcalbarrelalgo:HBModule/) }[0]
  divideHBModuleInEta(lp_HBModule)

  lp_HEModule = definitions.select { |e| e.name.match(/lp_hcalendcapalgo:HEModule/) }[0]

  divideHEModuleInZ(lp_HEModule)
  divideHEModuleInEta(lp_HEModule)

  Sketchup.active_model.commit_operation

end

##____________________________________________________________________________||
def divideHEModuleInZ(lp_HEModule)

  entities = lp_HEModule.entities

  lp_HEPart0 = entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^lp_hcalendcapalgo:HEPart0/) }[0].erase!
  lp_HEPart1 = entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^lp_hcalendcapalgo:HEPart1/) }[0].erase!

  divideHEModuleInZ_HEPart2(entities)
  divideHEModuleInZ_HEPart(entities, 3,  2,  6)
  divideHEModuleInZ_HEPart(entities, 4,  7, 12)
  divideHEModuleInZ_HEPart(entities, 5, 13, 18)

  end

##____________________________________________________________________________||
def  divideHEModuleInZ_HEPart2(entities)

  lp_HEPart2 = entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^lp_hcalendcapalgo:HEPart2/) }[0]
  lp_HEPart2Layer01Phi0Air = lp_HEPart2.definition.entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^lp_hcalendcapalgo:HEPart2Layer01Phi0Air/) }[0]
  lp_HEPart2Layer01Phi0Air.erase!
  lp_HEPart2Layer01Phi1Air = lp_HEPart2.definition.entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^lp_hcalendcapalgo:HEPart2Layer01Phi1Air/) }[0]
  lp_HEPart2Layer01Phi1Air.erase!

  solid_HEPart = lp_HEPart2.definition.entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^solid_hcalendcapalgo:HEPart2/) }[0]
  solid_HEPart.definition.name = "Layer%02d" % 1

  lp_HEPart2.explode


end

##____________________________________________________________________________||
def divideHEModuleInZ_HEPart(entities, hePartNo, layerStart, layerEnd)

  
  lp_HEPartName = "lp_hcalendcapalgo:HEPart" + hePartNo.to_s
  lp_HEPart = entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^#{lp_HEPartName}/) }[0]


  (layerStart..layerEnd).each do |layerNo|
    layerName = "Layer%02d" % layerNo
    regstr = "^#{lp_HEPartName}#{layerName}Phi0Air"
    layer = lp_HEPart.definition.entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/#{regstr}/) }[0]
    layer.erase!
  end

  solid_HEPartName = "solid_hcalendcapalgo:HEPart" + hePartNo.to_s
  solid_HEPart = lp_HEPart.definition.entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^#{solid_HEPartName}/) }[0]

  layers = [ ]
  (layerStart..layerEnd).each do |layerNo|
    layerName = "Layer%02d" % layerNo
    regstr = "^#{lp_HEPartName}#{layerName}Phi1Air"
    layers << lp_HEPart.definition.entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/#{regstr}/) }[0]
  end

  xmin = solid_HEPart.bounds.min.x
  xmax = layers[0].bounds.max.x
  ymin = 0
  ymax = [solid_HEPart.bounds.max.y*1.05, layers[0].bounds.max.y*1.05].max
  zmax = [solid_HEPart.bounds.max.z*1.05, layers[0].bounds.max.z*1.05].max
  zmin = - zmax

  solidCopy = entities.add_instance solid_HEPart.definition, solid_HEPart.transformation
  zbox = draw_z_box_for_HE(entities, xmin, xmax, ymin, ymax, zmin, zmax)
  group = solidCopy.intersect(zbox)
  instance =  group.to_component
  instance.definition.name = "Layer%02d" % layerStart
  
  (0..(layers.size - 2)).each do |i|
    layer0 = layers[i]
    layer1 = layers[i + 1]

    xmin = layer0.bounds.max.x
    xmax = layer1.bounds.max.x
    ymin = 0
    ymax = [layer0.bounds.max.y*1.05, layer1.bounds.max.y*1.05].max
    zmax = [layer0.bounds.max.z*1.05, layer1.bounds.max.z*1.05].max
    zmin = - zmax

    solidCopy = entities.add_instance solid_HEPart.definition, solid_HEPart.transformation
    zbox = draw_z_box_for_HE(entities, xmin, xmax, ymin, ymax, zmin, zmax)
    group = solidCopy.intersect(zbox)
    instance = group.to_component
    instance.definition.name = "Layer%02d" % (layerStart + i + 1)
  end

  layers.each { |l| l.erase! }
  solid_HEPart.erase!
  lp_HEPart.erase!

end

##____________________________________________________________________________||
def draw_z_box_for_HE(entities, xmin, xmax, ymin, ymax, zmin, zmax)

  points = Array.new
  points << Geom::Point3d.new(xmin,  ymin, zmax)
  points << Geom::Point3d.new(xmin,  ymax, zmax)
  points << Geom::Point3d.new(xmin,  ymin, zmin)
  points << Geom::Point3d.new(xmin,  ymax, zmin)
  points << Geom::Point3d.new(xmax,  ymin, zmax)
  points << Geom::Point3d.new(xmax,  ymax, zmax)
  points << Geom::Point3d.new(xmax,  ymin, zmin)
  points << Geom::Point3d.new(xmax,  ymax, zmin)

  draw_box_from_8_points(entities, points)
end


##____________________________________________________________________________||
def divideHEModuleInEta(lp_HEModule)

  entities = lp_HEModule.entities

  y_max = 3.m
  y_min = 0.3.m

  pi = Math.atan2(1, 1)*4
  theta = (90 - 90)*pi/180 

  hcalLayers = entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^Layer0[1-6]/) }
  etas = [1.305, 1.392, 1.479, 1.566, 1.653, 1.740, 1.830, 1.930, 2.043, 2.172, 2.322, 2.500, 2.650, 2.868, 3.000]
  (0..(etas.size - 2)).each do |ieta|
    eta1 = -etas[ieta]
    eta2 = -etas[ieta + 1]

    hcalLayers.each do |layer|
      layerCopy = entities.add_instance layer.definition, layer.transformation
      etabox = draw_eta_plane_box entities, eta1, eta2, theta, y_min, y_max, x_width = 1.2.m, z_origin = 0.m
      layerCopy.intersect(etabox)
    end
  end
  hcalLayers.each { |e| e.erase! }


  hcalLayers = entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^Layer(0[7890]|1[0-9])/) }
  etas = [1.305, 1.392, 1.479, 1.566, 1.653, 1.740, 1.830, 1.930, 2.043, 2.172, 2.322, 2.500, 2.650, 3.000]
  (0..(etas.size - 2)).each do |ieta|
    eta1 = -etas[ieta]
    eta2 = -etas[ieta + 1]

    hcalLayers.each do |layer|
      layerCopy = entities.add_instance layer.definition, layer.transformation
      etabox = draw_eta_plane_box entities, eta1, eta2, theta, y_min, y_max, x_width = 1.2.m, z_origin = 0.m
      layerCopy.intersect(etabox)
    end
  end
  hcalLayers.each { |e| e.erase! }

end

##____________________________________________________________________________||
def divideHBModuleInEta(lp_HBModule)

  entities = lp_HBModule.entities

  entitiesToExplode = entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^lp_hcalbarrelalgo:HBLayer/) }
  entitiesToExplode.each { |e| e.explode }

  entities = lp_HBModule.entities
  hcalLayers = entities.select { |e| e.typename == "ComponentInstance" and e.definition.name.match(/^solid_hcalbarrelalgo:HBLayer/) }

  etas = [0.000, 0.087, 0.174, 0.261, 0.348, 0.435, 0.522, 0.609, 0.696, 0.783, 0.870, 0.957, 1.044, 1.131, 1.218, 1.305, 1.392]
  y_max = 3.m
  y_min = 1.5.m

  pi = Math.atan2(1, 1)*4
  theta = (90 - 90)*pi/180 

  (0..(etas.size - 2)).each do |ieta|
    eta1 = -etas[ieta]
    eta2 = -etas[ieta + 1]

    hcalLayers.each do |layer|
      layerCopy = entities.add_instance layer.definition, layer.transformation
      etabox = draw_eta_plane_box entities, eta1, eta2, theta, y_min, y_max, x_width = 1.2.m, z_origin = 0.m
      layerCopy.intersect(etabox)
    end

  end
  hcalLayers.each { |e| e.erase! }


end

##____________________________________________________________________________||
def draw_eta_plane_box(entities, eta1, eta2, theta, y_min, y_max, x_width = 1.m, z_origin = 431.cm)

  pointInEta1, pointOutEta1 = getPointsForEta(eta1, theta, y_min, y_max)
  pointInEta2, pointOutEta2 = getPointsForEta(eta2, theta, y_min, y_max)

  points = Array.new
  points << pointInEta1  + [0, 0,   x_width/2.0 + z_origin]
  points << pointOutEta1 + [0, 0,   x_width/2.0 + z_origin]
  points << pointInEta1  + [0, 0, - x_width/2.0 + z_origin]
  points << pointOutEta1 + [0, 0, - x_width/2.0 + z_origin]
  points << pointInEta2  + [0, 0,   x_width/2.0 + z_origin]
  points << pointOutEta2 + [0, 0,   x_width/2.0 + z_origin]
  points << pointInEta2  + [0, 0, - x_width/2.0 + z_origin]
  points << pointOutEta2 + [0, 0, - x_width/2.0 + z_origin]

  draw_box_from_8_points(entities, points)

end

##____________________________________________________________________________||
def draw_box_from_8_points(entities, points)

  pointsList = Array.new
  pointsList << [points[0], points[1], points[3], points[2]]
  pointsList << [points[0], points[1], points[5], points[4]]
  pointsList << [points[1], points[5], points[7], points[3]]
  pointsList << [points[2], points[6], points[7], points[3]]
  pointsList << [points[0], points[2], points[6], points[4]]
  pointsList << [points[4], points[5], points[7], points[6]]

  group = entities.add_group
  entities = group.entities

  pointsList.each do |points|
    face = entities.add_face points
  end

  group

end

##____________________________________________________________________________||
def draw_eta_line(entities, eta, theta, y_min, y_max, z_origin = 431.cm)

  point1, point2 = getPointsForEta(eta, theta, y_min, y_max)

  point1 = point1 + [0, 0, z_origin]
  point2 = point2 + [0, 0, z_origin]

  line = entities.add_line point1,point2

end

##____________________________________________________________________________||
def getPointsForEta(eta, theta, y_min, y_max)

  def eta2theta eta
    return 2*Math.atan(Math.exp(-eta))
  end

  def theta2z theta, r
    return -r/Math.tan(theta)
  end

  z_out = theta2z(eta2theta(eta), y_max)
  z_in = theta2z(eta2theta(eta), y_min)
  point1 = Geom::Point3d.new(z_in,  y_min*Math.cos(theta), y_min*Math.sin(theta))
  point2 = Geom::Point3d.new(z_out, y_max*Math.cos(theta), y_max*Math.sin(theta))

  [point1, point2]
end

##____________________________________________________________________________||

cmsmain
