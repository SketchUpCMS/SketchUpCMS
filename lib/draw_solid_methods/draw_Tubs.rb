# Tai Sakuma <sakuma@fnal.gov>

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
