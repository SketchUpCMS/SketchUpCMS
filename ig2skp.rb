# <thomas.mccauley@cern.ch>

require 'sketchup.rb'
load 'bezier.rb'

# Careful! It is possible to parse the Types in the ig file
# and retrieve the file schema. However, for now, in the interest
# of expediency (but not robustness) we skip that step.
# We therefore hard-code things like collection names and
# variable indices.

module Ig2Skp

$rotationAboutZ = Geom::Transformation.rotation [0,0,0], [0,0,1], Math::PI*0.5
$rotationAboutY = Geom::Transformation.rotation [0,0,0], [0,1,0], Math::PI*0.5

def Ig2Skp.process_json(input)
	input.gsub!(/\s+/, "")
	input.gsub!(":", "=>")
	input.gsub!("\'", "\"")
	input.gsub!("(", "[")
	input.gsub!(")", "]")
	input.gsub!("nan", "0")
	input
end

def Ig2Skp.read_event(file_name)
	ein = File.open(file_name,"r")
	puts "Event file read"
	event = eval(Ig2Skp.process_json(ein.read()))
	ein.close
	event
end

def Ig2Skp.read_geometry(file_name)
	gin = File.open(file_name, "r")
	g = eval(gin.read())
	puts "Geometry file read"
	gin.close

	geometry = g["Collections"]
	geometry
end

def Ig2Skp.draw_tracks(entities, tracks, extras, assocs, pt_index, min_pt)
	puts "Draw tracks"

	assocs.each do |asc|     
    ti = asc[0][1]
    ei = asc[1][1] 

    track_pt = tracks[ti][pt_index]

    if track_pt > min_pt

      p1 = Geom::Point3d.new extras[ei][0][0].m, extras[ei][0][1].m, extras[ei][0][2].m   
      d1 = extras[ei][1]
      p2 = Geom::Point3d.new extras[ei][2][0].m, extras[ei][2][1].m, extras[ei][2][2].m
      d2 = extras[ei][3]
   
      p1.transform! $rotationAboutZ
      d1.transform! $rotationAboutZ
      p2.transform! $rotationAboutZ
      d2.transform! $rotationAboutZ

      p1.transform! $rotationAboutY
      d1.transform! $rotationAboutY
      p2.transform! $rotationAboutY
      d2.transform! $rotationAboutY

      #entities.add_cpoint p1
      #entities.add_cpoint p2
    
      v1 = Geom::Vector3d.new d1
     	v2 = Geom::Vector3d.new d2
      
      v1.normalize!
      v2.normalize!  
    
      # What's all this then?
      # Well, we know the beginning and end points of the track as well
      # as the directions at each of those points. This in-principle gives 
      # us the 4 control points needed for a cubic bezier spline. 
      # The control points from the directions are determined by moving along 0.25
      # of the distance between the beginning and end points of the track. 
      # This 0.25 is nothing more than a fudge factor that reproduces closely-enough
      # the NURBS-based drawing of tracks done in iSpy. At some point it may be nice
      # to implement the NURBS-based drawing but I value my sanity.

      distance = (p2[0]-p1[0])*(p2[0]-p1[0])+((p2[1]-p1[1])*(p2[1]-p1[1]))+((p2[2]-p2[1])*(p2[2]-p2[1]))
      distance = Math.sqrt(distance)

      scale = distance*0.25
     
      p3 = [p1[0]+ scale*v1[0], p1[1]+ scale*v1[1], p1[2]+ scale*v1[2]]
      p4 = [p2[0]- scale*v2[0], p2[1]- scale*v2[1], p2[2]- scale*v2[2]]
    
      pts = Bezier.points([p1,p3,p4,p2],16) 

      entities.add_curve pts

      # for debugging: this is a straight line connecting the 
      # innermost and outermost states
      # pts2 = [p1,p2]
      # entities.add_curve pts2

      # for debugging: these are the lines connecting the control points
      # to the first and last points
      # pts3 = [p1,p3]
      # pts4 = [p2,p4]
      # entities.add_curve pts3
      # entities.add_curve pts4
    end
  end
end

def Ig2Skp.draw_muons(entities, muons, points, assoc)
  puts "Draw muons"
  
  curve_points = {}

  for i in 0..muons.length-1
    curve_points[i] = []
  end

  assoc.each do |asc|
    mi = asc[0][1]
    pi = asc[1][1]

    points[pi][0].transform! $rotationAboutZ
    points[pi][0].transform! $rotationAboutY

    curve_points[mi].push(Geom::Point3d.new points[pi][0][0].m, points[pi][0][1].m, points[pi][0][2].m)
  end

  curve_points.each do |key, val|
    entities.add_curve val
  end
end

def Ig2Skp.draw_as_faces(entities, collection, material)
	puts "Draw as faces"

	collection.each do |d|
    front_1 = Geom::Point3d.new d[1]     
    front_2 = Geom::Point3d.new d[2]
    front_3 = Geom::Point3d.new d[3]
    front_4 = Geom::Point3d.new d[4]

    back_1 = Geom::Point3d.new d[5]
    back_2 = Geom::Point3d.new d[6]
    back_3 = Geom::Point3d.new d[7]
    back_4 = Geom::Point3d.new d[8]

    corners = [front_1, front_2, front_3, front_4, back_1, back_2, back_3, back_4]

    corners.each do |corner|
      corner.set! corner[0].m, corner[1].m, corner[2].m
    	corner.transform! $rotationAboutZ
      corner.transform! $rotationAboutY
    end

    # front
    front = entities.add_face corners[0], corners[1], corners[2], corners[3]
    front.material = material
    front.back_material = material
 
    # back
    back = entities.add_face corners[4], corners[5], corners[6], corners[7]
    back.material = material
    back.back_material = material
 
    # 4 sides
    side1 = entities.add_face corners[0], corners[4], corners[7], corners[3]
    side1.material = material
    side1.back_material = material
  
    side2 = entities.add_face corners[1], corners[5], corners[6], corners[2]
    side2.material = material
    side2.back_material = material
  
    top = entities.add_face corners[0], corners[4], corners[5], corners[1]
    top.material = material
    top.back_material = material
  
    bottom = entities.add_face corners[3], corners[7], corners[6], corners[2]
    bottom.material = material
    bottom.back_material = material
  end
end

def Ig2Skp.draw_rechits(entities, collection, material, min_energy, energy_scale) 
	puts "Draw rechits"

	collection.each do |rh|
    energy = rh[0]

    if energy > min_energy

      f1 = Geom::Point3d.new rh[5]
      f2 = Geom::Point3d.new rh[6]
      f3 = Geom::Point3d.new rh[7]
      f4 = Geom::Point3d.new rh[8]

      b1 = Geom::Point3d.new rh[9]
      b2 = Geom::Point3d.new rh[10]
      b3 = Geom::Point3d.new rh[11]
      b4 = Geom::Point3d.new rh[12]

      diff1 = b1-f1
      diff2 = b2-f2
      diff3 = b3-f3
      diff4 = b4-f4

      diff1.normalize!
      diff2.normalize!
      diff3.normalize!
      diff4.normalize!

      escaling = Geom::Transformation.scaling energy*energy_scale

      diff1.transform! escaling 
      diff2.transform! escaling
      diff3.transform! escaling
      diff4.transform! escaling

	    corners = [f1, f2, f3, f4, f1+diff1, f2+diff2, f3+diff3, f4+diff4]

	    corners.each do |corner|
        corner.set! corner[0].m, corner[1].m, corner[2].m
      	corner.transform! $rotationAboutZ
      	corner.transform! $rotationAboutY
    	end

      # front
      e01 = entities.add_line corners[0], corners[1]
      e12 = entities.add_line corners[1], corners[2]
      e23 = entities.add_line corners[2], corners[3]
      e30 = entities.add_line corners[3], corners[0]

      front = entities.add_face [e01,e12,e23,e30]
      if front
        front.material = material
        front.back_material = material
      end

      # back
      e45 = entities.add_line corners[4], corners[5]
      e56 = entities.add_line corners[5], corners[6]
      e67 = entities.add_line corners[6], corners[7]
      e74 = entities.add_line corners[7], corners[4]

      back = entities.add_face [e45,e56,e67,e74]
      if back
        back.material = material
        back.back_material = material
      end

      # connect the corners 
      e04 = entities.add_line corners[0], corners[4]
      e15 = entities.add_line corners[1], corners[5]
      e26 = entities.add_line corners[2], corners[6]
      e37 = entities.add_line corners[3], corners[7]
  
 	    top = entities.add_face [e04,e01,e15,e45]
    	if top  
       	top.material = material
        top.back_material = material
      end

      bottom = entities.add_face [e37,e23,e26,e67]
      if bottom
        bottom.material = material
        bottom.back_material = material
      end

      side1 = entities.add_face [e12,e26,e56,e15]
      if side1
        side1.material = material
        side1.back_material = material
      end

      side2 = entities.add_face [e30,e37,e74,e04]
      if side2
        side2.material = material
        side2.back_material = material
      end
   	end
	end
end

end # end of ig2skp module
file_loaded("ig2skp")