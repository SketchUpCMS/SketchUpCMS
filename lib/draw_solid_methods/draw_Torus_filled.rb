# Tai Sakuma <sakuma@fnal.gov>

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
