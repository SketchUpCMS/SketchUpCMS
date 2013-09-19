# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
def draw_Torus_2pi(entities, args)

  def definePathToFollow(entities, args)
    center = [- args["outerRadius"] - 1.cm, 0, 0]
    norm = [1, 0, 0]
    norm.normalize!
    num_segments_per_pi = 36
    num_segments = num_segments_per_pi*2
    radius = args["torusRadius"]
    pathToFollow = entities.add_circle center, norm, radius, num_segments
    pathToFollow
  end

  def defineFace(entities, args)
    center = [0, args["torusRadius"], 0]
    norm = [0, 0, 1]
    norm.normalize!
    num_segments_per_pi = 18
    num_segments = num_segments_per_pi*2
    radius = args["outerRadius"]
    circle1 = entities.add_circle center, norm, radius, num_segments
    if args["innerRadius"] > 0
      radius = args["innerRadius"]
      circle2 = entities.add_circle center, norm, radius, num_segments
      face2 = entities.add_face circle2
    end
    face1 = entities.add_face circle1
    face2.erase! if face2
    face1
  end

  def reverseFacesIfInward(entities)
    def isInward(entities)
      unitZ = Geom::Vector3d.new 1, 0, 0
      zmax =  - 500000.m
      for e in entities
        next if e.typename != "Face"
        if zmax <= e.bounds.center[0]
          zmax = e.bounds.center[0]
          headFaceNomal = e.normal
        end
      end
      return headFaceNomal.dot(unitZ) < 0
    end
    def reverseFaces(entities)
      for e in entities
        next if e.typename != "Face"
        e.reverse!
      end
    end
    if isInward(entities)
      reverseFaces(entities)
    end
  end

  group = entities.add_group
  entities = group.entities
  pathToFollow = definePathToFollow entities, args
  face = defineFace entities, args
  face.followme pathToFollow
  pathToFollow.each { |e| e.erase! }
  reverseFacesIfInward(entities)
  group
end

##____________________________________________________________________________||
