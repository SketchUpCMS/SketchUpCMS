# Tai Sakuma <sakuma@fnal.gov>

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
