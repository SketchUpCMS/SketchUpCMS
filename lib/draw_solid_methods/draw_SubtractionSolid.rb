# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
def draw_SubtractionSolid entities, args

  group = entities.add_group
  entities = group.entities

  origin = Geom::Point3d.new 0, 0, 0
  transform = Geom::Transformation.new origin

  solid0 = entities.add_instance args['rSolid'][0], transform
  solid1 = entities.add_instance args['rSolid'][1], transform

  transform = args['rRotation']*transform if args.key?('rRotation')
  transform = args['Translation']*transform  if args.key?('Translation')

  solid1.transform! transform 

  solid = solid1.subtract(solid0)
  solid.explode

  group

end

##____________________________________________________________________________||
