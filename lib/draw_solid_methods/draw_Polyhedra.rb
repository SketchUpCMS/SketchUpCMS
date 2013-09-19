# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
def draw_Polyhedra entities, args
  if (2*Math::PI - args["deltaPhi"]).abs < 10**(-10)
    return draw_Polyhedra_2pi(entities, args)
  else
    return draw_Polyhedra_lt2pi(entities, args)
  end
end

##____________________________________________________________________________||
