# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'


##____________________________________________________________________________||
def cmsmain

  Sketchup.active_model.start_operation("do layers", true)

  move_layer_BEAM
  move_layer_MGNT
  move_layer_ECAL
  move_layer_HBModules
  move_layer_HEModules

  layer_MGNT = Sketchup.active_model.layers.select { |l| l.name == "MGNT"}[0]
  layer_MGNT.visible = false

  layer_ECAL = Sketchup.active_model.layers.select { |l| l.name == "ECAL"}[0]
  layer_ECAL.visible = false

  layer_HBModule = Sketchup.active_model.layers.select { |l| l.name == "HBModule"}[0]
  layer_HBModule.visible = false

  layer_HEModule = Sketchup.active_model.layers.select { |l| l.name == "HEModule"}[0]
  layer_HEModule.visible = false

  add_rotated_HCAL_modules

  Sketchup.active_model.commit_operation

end

##____________________________________________________________________________||
def add_rotated_HCAL_modules

  layers = Sketchup.active_model.layers
  layerCurrent = layers.add "current"
  layerUpgrade = layers.add "upgrade"

  hbModule = place_HBModule
  heModule = place_HEModule
  hbModule.layer = layerCurrent
  heModule.layer = layerCurrent

  hbModule = place_HBModule
  heModule = place_HEModule
  hbModule.layer = layerUpgrade
  heModule.layer = layerUpgrade

end

##____________________________________________________________________________||
def place_HBModule


  definitions = Sketchup.active_model.definitions
  lp_HB_def = definitions.select { |e| e.name.match(/^lp_hcalbarrelalgo:HB$/) }[0]
  entities = lp_HB_def.entities

  lp_HBModule_def = definitions.select { |e| e.name.match(/^lp_hcalbarrelalgo:HBModule/) }[0]

  pi = Math.atan2(1, 1)*4
  transformation = Geom::Transformation.new
  rotation = Geom::Transformation.rotation( Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(1, 0, 0), pi/2.0)

  entities.add_instance lp_HBModule_def, transformation*rotation

end

##____________________________________________________________________________||
def place_HEModule


  definitions = Sketchup.active_model.definitions
  lp_HE_def = definitions.select { |e| e.name.match(/^lp_hcalendcapalgo:HE$/) }[0]
  entities = lp_HE_def.entities

  lp_HEModule_def = definitions.select { |e| e.name.match(/^lp_hcalendcapalgo:HEModule/) }[0]

  pi = Math.atan2(1, 1)*4
  transformation = Geom::Transformation.new
  rotation = Geom::Transformation.rotation( Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(1, 0, 0), pi/2.0)

  entities.add_instance lp_HEModule_def, transformation*rotation

end

##____________________________________________________________________________||
def move_layer_BEAM

  layers = Sketchup.active_model.layers
  newLayer = layers.add "BEAM"

  definitions = Sketchup.active_model.definitions
  lp_defs = definitions.select { |e| e.name.match(/^lp_beampipe:BEAM/) }
  lp_defs.each do |lp_def|
    lp_def.instances.each { |i| i.layer = newLayer }
  end


end

##____________________________________________________________________________||
def move_layer_MGNT

  layers = Sketchup.active_model.layers
  newLayer = layers.add "MGNT"

  definitions = Sketchup.active_model.definitions
  lp_def = definitions.select { |e| e.name.match(/^lp_mgnt:MGNT/) }[0]
  lp_ins = lp_def.instances[0]
  lp_ins.layer = newLayer

end

##____________________________________________________________________________||
def move_layer_ECAL

  layers = Sketchup.active_model.layers
  newLayer = layers.add "ECAL"

  definitions = Sketchup.active_model.definitions
  lp_def = definitions.select { |e| e.name.match(/^lp_eregalgo:ECAL/) }[0]
  lp_ins = lp_def.instances[0]
  lp_ins.layer = newLayer

end

##____________________________________________________________________________||
def move_layer_HCAL

  layers = Sketchup.active_model.layers
  newLayer = layers.add "HCAL"

  definitions = Sketchup.active_model.definitions
  lp_def = definitions.select { |e| e.name.match(/^lp_hcalalgo:HCal/) }[0]
  lp_ins = lp_def.instances[0]
  lp_ins.layer = newLayer

end

##____________________________________________________________________________||
def move_layer_HBModules
  layers = Sketchup.active_model.layers
  newLayer = layers.add "HBModule"

  definitions = Sketchup.active_model.definitions
  lp_def = definitions.select { |e| e.name.match(/^lp_hcalbarrelalgo:HBHalf/) }[0]
  lp_def.instances.each { |i| i.explode }

  lp_def = definitions.select { |e| e.name.match(/^lp_hcalbarrelalgo:HBModule/) }[0]
  lp_def.instances.each { |i| i.layer = newLayer }

end

##____________________________________________________________________________||
def move_layer_HEModules
  layers = Sketchup.active_model.layers
  newLayer = layers.add "HEModule"

  definitions = Sketchup.active_model.definitions
  lp_def = definitions.select { |e| e.name.match(/^lp_hcalendcapalgo:HE$/) }[0]
  lp_def.instances[1].make_unique


  lp_def = definitions.select { |e| e.name.match(/^lp_hcalendcapalgo:HEFront$/) }[0]
  lp_def.instances.each { |i| i.explode }

  lp_def = definitions.select { |e| e.name.match(/^lp_hcalendcapalgo:HEModule$/) }[0]
  lp_def.instances.each { |i| i.layer = newLayer }

end

##____________________________________________________________________________||



cmsmain
