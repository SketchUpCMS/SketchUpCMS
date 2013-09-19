# Tai Sakuma <sakuma@fnal.gov>

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
