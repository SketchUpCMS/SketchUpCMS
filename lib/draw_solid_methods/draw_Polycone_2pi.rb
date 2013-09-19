# Tai Sakuma <sakuma@fnal.gov>

##____________________________________________________________________________||
def draw_Polycone_2pi entities, args

  def definePathToFollow(entities, args)
    zmin = args["ZSection"].map { |i| i["z"] }.min
    center = [zmin - 1.cm, 0, 0]
    norm = [1, 0, 0]
    norm.normalize!

    num_segments_per_pi = 36
    num_segments = num_segments_per_pi*2

    radius = args["ZSection"].map { |i| [i["rMin"], i["rMax"]] }.flatten.delete_if { |l| l == 0 }.min*0.5

    pathToFollow = entities.add_circle center, norm, radius, num_segments
    pathToFollow
  end

  def defineFace(entities, args)
    edges = Array.new
    args["ZSection"].each do |sec|
      edge = Geom::Point3d.new(sec["z"], sec["rMax"], 0)
      edges << edge unless edges.include?(edge)
    end
    args["ZSection"].reverse.each do |sec|
      edge = Geom::Point3d.new(sec["z"], sec["rMin"], 0)
      edges << edge unless edges.include?(edge)
    end
    face = entities.add_face edges
    face
  end

  def reverseFacesIfInward(entities, args)
    def isInward(entities, args)
      unitZ = Geom::Vector3d.new 1, 0, 0
      zmax = args["ZSection"].map { |i| i["z"] }.min - 1.cm
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
    if isInward(entities, args)
      reverseFaces(entities)
    end
  end

  group = entities.add_group
  entities = group.entities
  pathToFollow = definePathToFollow entities, args
  face = defineFace entities, args
  face.followme pathToFollow
  pathToFollow.each { |e| e.erase! }
  reverseFacesIfInward(entities, args)

  group
end

##____________________________________________________________________________||
