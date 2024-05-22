# Tai Sakuma <sakuma@fnal.gov>
# Thomas McCauley <thomas.mccauley@cern.ch>
require 'sketchup'

require File.dirname(__FILE__) + '/sitecfg.rb'

load 'solids.rb'

##____________________________________________________________________________||
def draw_solids

  def test_draw_Box entities
    box = draw_Box entities, {"dx" => 0.2.m, "dy" => 0.3.m, "dz" => 0.5.m}
    box.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 0, 0.3.m))

    model = Sketchup.active_model
    layer = model.layers.add(model.layers.unique_name('Box'))
    box.layer = layer
  end

  def test_draw_Cone entities
    args = Hash.new
    args["startPhi"] = 210.degrees
    args["deltaPhi"] = 240.degrees
    args["dz"] = 0.5.m
    args["rMin1"] = 0.1.m
    args["rMax1"] = 0.2.m
    args["rMin2"] = 0.2.m
    args["rMax2"] = 0.3.m
    s1 = draw_Cone entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 1.m, 0.3.m))

    model = Sketchup.active_model
    layer = model.layers.add(model.layers.unique_name('Cone'))
    s1.layer = layer
  end

  def test_draw_Polycone entities
    args = Hash.new
    args["startPhi"] = 210.degrees
    args["deltaPhi"] = 240.degrees
    args["ZSection"] = Array.new
    args["ZSection"] << {"z" => -0.5.m, "rMin" => 0.1.m, "rMax" => 0.3.m}
    args["ZSection"] << {"z" => -0.2.m, "rMin" => 0.2.m, "rMax" => 0.4.m}
    args["ZSection"] << {"z" =>  0.4.m, "rMin" => 0.2.m, "rMax" => 0.3.m}
    s1 = draw_Polycone entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 2.m, 0.4.m))

    model = Sketchup.active_model
    layer = model.layers.add(model.layers.unique_name('Polycone'))
    s1.layer = layer
  end

  def test_draw_Tubs entities
    s1 = draw_Tubs entities, {"dz" => 0.5.m, "startPhi" => 210.degrees, "deltaPhi" => 240.degrees, "rMin" => 0.3.m, "rMax" => 0.4.m}
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 3.m, 0.4.m))

    model = Sketchup.active_model
    layer = model.layers.add(model.layers.unique_name('Tubs'))
    s1.layer = layer
  end
  
  def test_draw_Torus entities
    args = Hash.new
    args["innerRadius"] = 0.05.m
    args["outerRadius"] = 0.1.m
    args["deltaPhi"] = 240.degrees
    args["startPhi"] = 210.degrees
    args["torusRadius"] = 0.3.m
    s1 = draw_Torus entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 4.m, 0.4.m))

    model = Sketchup.active_model
    layer = model.layers.add(model.layers.unique_name('Torus'))
    s1.layer = layer
  end

  def test_draw_Polyhedra entities
    args = {
      "ZSection"=>[
                   {"rMax"=>0.4.m, "rMin"=>0.3.m, "z"=>-0.5.m},
                   {"rMax"=>0.3.m, "rMin"=>0.2.m, "z"=>-0.2.m},
                   {"rMax"=>0.4.m, "rMin"=>0.3.m, "z"=>0.5.m},
                  ],
      "deltaPhi"=>240.degrees,
      "startPhi"=>210.degrees,
      "numSide"=>6}
    s1 = draw_Polyhedra entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 5.m, 0.4.m))

    model = Sketchup.active_model
    layer = model.layers.add(model.layers.unique_name('Polyhedra'))
    s1.layer = layer
  end

  def test_draw_PseudoTrap entities
    args = {
      "dx1"=>0.1.m, "dx2"=>0.4.m,
      "dy1"=>0.1.m, "dy2"=>0.1.m,
      "dz"=>0.5.m
    }
    s1 = draw_PseudoTrap entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 6.m, 0.1.m))

    model = Sketchup.active_model
    layer = model.layers.add(model.layers.unique_name('PseudoTrap'))
    s1.layer = layer
  end

  def test_draw_Trapezoid entities
    args = {
      "dz"=>0.5.m, "theta"=>20.0.degrees, "phi"=>0.0,
      "h1"=>0.2.m, "bl1"=>0.15.m, "tl1"=>0.150.m, "alp1"=>10.0.degrees,
      "h2"=>0.2.m, "bl2"=>0.304.m, "tl2"=>0.304.m, "alp2"=>10.0.degrees
    }
    s1 = draw_Trapezoid entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 7.m, 0.m))

    model = Sketchup.active_model
    layer = model.layers.add(model.layers.unique_name('Trapezoid'))
    s1.layer = layer
  end

  def test_draw_ExtrudedPolygon entities
    args = Hash.new

    args["XYPoint"] = Array.new
    args["XYPoint"] << { "x" => -0.3.m, "y" => -0.3.m }
    args["XYPoint"] << { "x" => -0.3.m, "y" => 0.3.m }
    args["XYPoint"] << { "x" => 0.3.m, "y" => 0.3.m }
    args["XYPoint"] << { "x" => 0.3.m, "y" => -0.3.m }
    args["XYPoint"] << { "x" => 0.15.m, "y" => -0.3.m }
    args["XYPoint"] << { "x" => 0.15.m, "y" => 0.15.m }
    args["XYPoint"] << { "x" => -0.15.m, "y" => 0.15.m }
    args["XYPoint"] << { "x" => -0.15.m, "y" => -0.3.m }
    
    args["ZXYSection"] = Array.new
    args["ZXYSection"] << { "z" => -0.4.m, "x" => -0.2.m, "y" => 0.1.m, "scale" => 1.5}
    args["ZXYSection"] << { "z" => 0.1.m, "x" => 0.m, "y" => 0.m, "scale" => 0.5} 
    args["ZXYSection"] << { "z" => 0.1.m, "x" => 0.m, "y" => 0.m, "scale" => 0.7}
    args["ZXYSection"] << { "z" => 0.4.m, "x" => 0.m, "y" => 0.2.m, "scale" => 0.9}

    ep = draw_ExtrudedPolygon entities, args
    ep.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 8.m, 0.3.m))

    model = Sketchup.active_model
    layer = model.layers.add(model.layers.unique_name('ExtrudedPolygon'))
    ep.layer = layer
  end
  
  def test_draw_TruncTubs entities
    args = {
      "zHalf" => 0.5.m, "rMin" => 0.2.m, "rMax" => 0.4.m,
      "startPhi" => 0.0.degrees, "deltaPhi" => 90.0.degrees,
      "cutAtStart" => 0.25.m, "cutAtDelta" => 0.35.m, "cutInside" => true
    }
    
    tt_inside = draw_TruncTubs entities, args
    tt_inside.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 9.m, 0.3.m))
    
    model = Sketchup.active_model
    layer = model.layers.add(model.layers.unique_name('TruncTubs_cutInside'))
    tt_inside.layer = layer

    args["cutInside"] = false

    tt_outside = draw_TruncTubs entities, args
    tt_outside.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 10.m, 0.3.m))
    layer = model.layers.add(model.layers.unique_name('TruncTubs_cutOutside'))
    tt_outside.layer = layer
  end
  
  def test_draw_UnionSolid entities

    # CHIMNEY_HOLE_N_c
    solid1 = draw_Box(entities, {"dz"=>16.3385826771653, "dx"=>5.90551181102362, "dy"=>9.84251968503937})
    solid1 = solid1.to_component.definition

    # CHIMNEY_HOLE_N_a
    solid2 = draw_Tubs(entities, {"rMax"=>28.5433070866142, "dz"=>16.3385826771653, "deltaPhi"=>3.14159265358979, "rMin"=>0.0, "startPhi"=>1.5707963267949})
    solid2 = solid2.to_component.definition

    entities.clear! 

    origin = Geom::Point3d.new 0, 0, 0
    transform = Geom::Transformation.new origin

    rotation = Geom::Transformation.new origin

    vector = Geom::Vector3d.new 0, -0.15.m, 0
    translation = Geom::Transformation.translation vector

    args = Hash.new
    args["rSolid"] = [solid1, solid2]
    args["rRotation"] = rotation
    args["Translation"] = translation
    draw_UnionSolid(entities, args)

    # {"rSolid"=>[{"name"=>"CHIMNEY_HOLE_N_c"}, {"name"=>"CHIMNEY_HOLE_N_a"}], "rRotation"=>[{"name"=>"rotations:000D"}], "Translation"=>[{"x"=>"-0.15*m", "y"=>"0.*fm", "z"=>"0.*fm"}]}

  end
  
  def test_draw_SubtractionSolid entities

    # "MGNT_0"
    args = Hash.new
    args["startPhi"] = 0
    args["deltaPhi"] = 6.28318530717959
    args["ZSection"] = Array.new
    args["ZSection"] << {"rMax"=>148.425196850394, "z"=>-255.905511811024, "rMin"=>116.929133858268}
    args["ZSection"] << {"rMax"=>148.425196850394, "z"=>-86.6141732283465, "rMin"=>116.929133858268}
    args["ZSection"] << {"rMax"=>149.606299212598, "z"=>-86.6141732283465, "rMin"=>116.929133858268}
    args["ZSection"] << {"rMax"=>149.606299212598, "z"=>86.6141732283465,  "rMin"=>116.929133858268}
    args["ZSection"] << {"rMax"=>148.425196850394, "z"=>86.6141732283465,  "rMin"=>116.929133858268}
    args["ZSection"] << {"rMax"=>148.425196850394, "z"=>255.905511811024,  "rMin"=>116.929133858268}
    solid1 = draw_Polycone(entities, args)
    solid1 = solid1.to_component.definition

    # "CHIMNEY_HOLE_P"
    solid2 = draw_Tubs(entities, {"rMax"=>18.8976377952756, "dz"=>16.3385826771653, "deltaPhi"=>6.28318530717959, "rMin"=>0.0, "startPhi"=>0.0})
    solid2 = solid2.to_component.definition

    entities.clear! 

    origin = Geom::Point3d.new 0, 0, 0

    # RMCHIMHOLEP" thetaX="90*deg" phiX="00*deg" thetaY="180*deg" phiY="90*deg" thetaZ="90*deg" phiZ="90*deg"/>
    xaxis = Geom::Vector3d.new Math::cos(Math::PI/2), Math::sin(Math::PI/2)*Math::cos(0), Math::sin(Math::PI/2)*Math::sin(0)
    yaxis = Geom::Vector3d.new Math::cos(Math::PI), Math::sin(Math::PI)*Math::cos(Math::PI/2), Math::sin(Math::PI)*Math::sin(Math::PI/2)
    zaxis = Geom::Vector3d.new Math::cos(Math::PI/2), Math::sin(Math::PI/2)*Math::cos(Math::PI/2), Math::sin(Math::PI/2)*Math::sin(Math::PI/2)
    rotation = Geom::Transformation.axes origin, zaxis, xaxis, yaxis

    vector = Geom::Vector3d.new 1.471.m, 0, 3.385.m
    translation = Geom::Transformation.translation vector
    args = Hash.new
    args["rSolid"] = [solid1, solid2]
    args["rRotation"] = rotation
    args["Translation"] = translation
    draw_SubtractionSolid(entities, args)

  end


  model = Sketchup.active_model

  model.layers.purge_unused

  entities = model.entities

  test_draw_Box entities
  test_draw_Cone entities
  test_draw_Polycone entities
  test_draw_Tubs entities
  test_draw_Torus entities
  test_draw_Polyhedra entities
  test_draw_PseudoTrap entities
  test_draw_Trapezoid entities
  test_draw_ExtrudedPolygon entities
  test_draw_TruncTubs entities
  
  # test_draw_Cylinder entities
  # test_draw_Polycone_2pi entities
  # test_draw_Polycone_BeamVacuum5 entities
  # test_draw_CALO entities
  # test_draw_UnionSolid entities
  # test_draw_SubtractionSolid entities
end

draw_solids
