# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

require File.dirname(__FILE__) + '/sitecfg.rb'

load 'solids.rb'

##____________________________________________________________________________||
def test_draw_solids

  def test_draw_Box entities
    draw_Box entities, {"dx" => 1.m, "dy" => 2.m, "dz" => 5.m}
  end

  def test_draw_Cylinder entities
    startPhis = [0, 10, 20, 30, 45, 90, 180, 270]
    deltaPhis = [10, 20, 30, 45, 90, 180, 270, 300, 360]

    z = 0.m
    startPhis.each do |startPhi|
      y = 0.m
      z += 10.m
      deltaPhis.each do |deltaPhi|
        y += 10.m
        s1 = draw_Cylinder entities, {"dz" => 5.m, "startPhi" => startPhi.degrees, "deltaPhi" => deltaPhi.degrees, "rMax" => 3.m}
        s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, y, z))
      end
    end
    
  end

  def test_draw_Tubs entities
    startPhis = [0, 20, 30, 45, 90, 180, 270]
    deltaPhis = [20, 30, 45, 90, 180, 270, 300, 360]
    rMax = 3.m
    rMins = [0.m, 1.m]

    z = 0.m
    startPhis.each do |startPhi|
      z += 10.m
      y = 0.m
      deltaPhis.each do |deltaPhi|
        y += 10.m
        x = 0
        rMins.each do |rMin|
          x += 100.m
          s1 = draw_Tubs entities, {"dz" => 5.m, "startPhi" => startPhi.degrees, "deltaPhi" => deltaPhi.degrees, "rMin" => rMin, "rMax" => rMax}
          s1.move! Geom::Transformation.translation(Geom::Vector3d.new(x, y, z))
        end
      end
    end
    
  end

  def test_draw_Polycone_2pi entities
    args = Hash.new
    args["ZSection"] = Array.new
    args["ZSection"] << {"z" => -5.m, "rMin" => 0.m, "rMax" => 0.m}
    args["ZSection"] << {"z" => -4.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" => -3.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" => -3.m, "rMin" => 2.m, "rMax" => 3.m}
    args["ZSection"] << {"z" =>  3.m, "rMin" => 2.m, "rMax" => 3.m}
    args["ZSection"] << {"z" =>  3.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" =>  4.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" =>  5.m, "rMin" => 0.m, "rMax" => 0.m}
    s1 = draw_Polycone_2pi entities, args

  end

  def test_draw_Polycone entities
    args = Hash.new
    args["startPhi"] = 0.degrees
    args["deltaPhi"] = 180.degrees
    args["ZSection"] = Array.new
    args["ZSection"] << {"z" => -5.m, "rMin" => 0.m, "rMax" => 0.m}
    args["ZSection"] << {"z" => -4.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" => -3.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" => -3.m, "rMin" => 2.m, "rMax" => 3.m}
    args["ZSection"] << {"z" =>  3.m, "rMin" => 2.m, "rMax" => 3.m}
    args["ZSection"] << {"z" =>  3.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" =>  4.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" =>  5.m, "rMin" => 0.m, "rMax" => 0.m}
    s1 = draw_Polycone entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 0, 50.m))

    args = Hash.new
    args["startPhi"] = 0.degrees
    args["deltaPhi"] = 180.degrees
    args["ZSection"] = Array.new
    args["ZSection"] << {"z" => -5.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" =>  4.m, "rMin" => 0.m, "rMax" => 3.m}
    s1 = draw_Polycone entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 0, 40.m))

    args = Hash.new
    args["startPhi"] = 0.degrees
    args["deltaPhi"] = 180.degrees
    args["ZSection"] = Array.new
    args["ZSection"] << {"z" => -5.m, "rMin" => 1.m, "rMax" => 3.m}
    args["ZSection"] << {"z" =>  4.m, "rMin" => 2.m, "rMax" => 3.m}
    s1 = draw_Polycone entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 0, 30.m))

    args = Hash.new
    args["startPhi"] = 0.degrees
    args["deltaPhi"] = 45.degrees
    args["ZSection"] = Array.new
    args["ZSection"] << {"z" => -5.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" => -2.m, "rMin" => 0.m, "rMax" => 4.m}
    args["ZSection"] << {"z" =>  4.m, "rMin" => 0.m, "rMax" => 3.m}
    s1 = draw_Polycone entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 0, 20.m))

    args = Hash.new
    args["startPhi"] = 0.degrees
    args["deltaPhi"] = 360.degrees
    args["ZSection"] = Array.new
    args["ZSection"] << {"z" => -5.m, "rMin" => 0.m, "rMax" => 3.m}
    args["ZSection"] << {"z" => -2.m, "rMin" => 0.m, "rMax" => 4.m}
    args["ZSection"] << {"z" =>  4.m, "rMin" => 0.m, "rMax" => 3.m}
    s1 = draw_Polycone entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 0, 10.m))

    args = Hash.new
    args["startPhi"] = 0.degrees
    args["deltaPhi"] = 360.degrees
    args["ZSection"] = Array.new
    args["ZSection"] << {"z" => -5.m, "rMin" => 1.m, "rMax" => 3.m}
    args["ZSection"] << {"z" => -2.m, "rMin" => 2.m, "rMax" => 4.m}
    args["ZSection"] << {"z" =>  4.m, "rMin" => 2.m, "rMax" => 3.m}
    s1 = draw_Polycone entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 0, 0.m))

  end

  def test_draw_CALO entities
    args = Hash.new
    args["startPhi"] = 0
    args["deltaPhi"] = 6.28318530717959
    args["ZSection"] = Array.new
    args["ZSection"] << {"z" => -218.149606299213, "rMin" => 3.51574803149606, "rMax" => 116.141732283465}
    args["ZSection"] << {"z" => -125.196850393701, "rMin" => 3.1496062992126 , "rMax" => 116.141732283465}
    args["ZSection"] << {"z" => -115.551181102362, "rMin" => 2.91338582677165, "rMax" => 116.141732283465}
    args["ZSection"] << {"z" => -115.551181102362, "rMin" => 48.5433070866142, "rMax" => 116.141732283465}
    args["ZSection"] << {"z" =>  115.551181102362, "rMin" => 48.5433070866142, "rMax" => 116.141732283465}
    args["ZSection"] << {"z" =>  115.551181102362, "rMin" => 2.91338582677165, "rMax" => 116.141732283465}
    args["ZSection"] << {"z" =>  125.196850393701, "rMin" => 3.1496062992126 , "rMax" => 116.141732283465}
    args["ZSection"] << {"z" =>  218.149606299213, "rMin" => 3.51574803149606, "rMax" => 116.141732283465}
    s1 = draw_Polycone entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 0, 40.m))
  end


  def test_draw_Polycone_BeamVacuum5 entities
    args = Hash.new
    args["startPhi"] = 0
    args["deltaPhi"] = 6.28318530717959
    args["ZSection"] = Array.new
    args["ZSection"] << {"z"=>76.3779527559055, "rMax"=>1.14173228346457, "rMin"=>0.0}
    args["ZSection"] << {"z"=>76.6929133858268, "rMax"=>1.14173228346457, "rMin"=>0.0}
    args["ZSection"] << {"z"=>92.3622047244095, "rMax"=>1.375,            "rMin"=>0.0}
    args["ZSection"] << {"z"=>92.3622047244095, "rMax"=>1.3740157480315,  "rMin"=>0.0}
    args["ZSection"] << {"z"=>93.3543307086614, "rMax"=>1.3740157480315,  "rMin"=>0.0}
    s1 = draw_Polycone entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(0, 0, 40.m))
  end

  def test_draw_Torus entities
    args = Hash.new
    args["innerRadius"] = 0
    args["outerRadius"] = 0.5.m
    args["deltaPhi"] = 6.28318530717959
    args["startPhi"] = 0.0
    args["torusRadius"] = 1.m
    s1 = draw_Torus entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(2.m, 0, 0))

    args = Hash.new
    args["innerRadius"] = 0.2.m
    args["outerRadius"] = 0.5.m
    args["deltaPhi"] = 6.28318530717959
    args["startPhi"] = 0
    args["torusRadius"] = 1.m
    s1 = draw_Torus entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(4.m, 0, 0))

    args = Hash.new
    args["innerRadius"] = 0.2.m
    args["outerRadius"] = 0.5.m
    args["deltaPhi"] = 120.degrees
    args["startPhi"] = 10.degrees
    args["torusRadius"] = 1.m
    s1 = draw_Torus entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(6.m, 0, 0))
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

  def test_draw_Polyhedra entities
    args = {"ZSection"=>[{"rMax"=>113.248031496063, "rMin"=>69.8818897637795, "z"=>0}, {"rMax"=>113.248031496063, "rMin"=>69.8818897637795, "z"=>121.353921570141}, {"rMax"=>113.248031496063, "rMin"=>75.8858267716535, "z"=>131.795088037967}, {"rMax"=>113.248031496063, "rMin"=>75.8858267716535, "z"=>143.20094531472}, {"rMax"=>113.248031496063, "rMin"=>79.8110236220472, "z"=>150.614361038125}, {"rMax"=>113.248031496063, "rMin"=>38.0886220439488, "z"=>158.149606299213}, {"rMax"=>108.444881889764, "rMin"=>38.0886220439488, "z"=>158.149606299213}, {"rMax"=>108.444881889764, "rMin"=>106.267716535433, "z"=>170.551181102362}], "deltaPhi"=>6.28318530717959, "startPhi"=>-0.174532925199433, "numSide"=>18}
    s1 = draw_Polyhedra entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(16.m, 0, 0))

    args = {"ZSection"=>[{"rMax"=>113.248031496063, "rMin"=>69.8818897637795, "z"=>0}, {"rMax"=>113.248031496063, "rMin"=>69.8818897637795, "z"=>121.353921570141}, {"rMax"=>113.248031496063, "rMin"=>75.8858267716535, "z"=>131.795088037967}, {"rMax"=>113.248031496063, "rMin"=>75.8858267716535, "z"=>143.20094531472}, {"rMax"=>113.248031496063, "rMin"=>79.8110236220472, "z"=>150.614361038125}, {"rMax"=>113.248031496063, "rMin"=>38.0886220439488, "z"=>158.149606299213}, {"rMax"=>108.444881889764, "rMin"=>38.0886220439488, "z"=>158.149606299213}, {"rMax"=>108.444881889764, "rMin"=>106.267716535433, "z"=>170.551181102362}], "deltaPhi"=>0.349065850398866*2, "startPhi"=>-0.174532925199433, "numSide"=>2}
    s1 = draw_Polyhedra entities, args
    s1.move! Geom::Transformation.translation(Geom::Vector3d.new(8.m, 0, 0))

    args = {"ZSection"=>[{"rMax"=>113.248031496063, "rMin"=>69.8818897637795, "z"=>0}, {"rMax"=>113.248031496063, "rMin"=>69.8818897637795, "z"=>121.353921570141}, {"rMax"=>113.248031496063, "rMin"=>75.8858267716535, "z"=>131.795088037967}, {"rMax"=>113.248031496063, "rMin"=>75.8858267716535, "z"=>143.20094531472}, {"rMax"=>113.248031496063, "rMin"=>79.8110236220472, "z"=>150.614361038125}, {"rMax"=>113.248031496063, "rMin"=>38.0886220439488, "z"=>158.149606299213}, {"rMax"=>108.444881889764, "rMin"=>38.0886220439488, "z"=>158.149606299213}, {"rMax"=>108.444881889764, "rMin"=>106.267716535433, "z"=>170.551181102362}], "deltaPhi"=>0.349065850398866, "startPhi"=>-0.174532925199433, "numSide"=>1}
    s1 = draw_Polyhedra entities, args

  end

  model = Sketchup.active_model
  entities = model.entities

  # test_draw_Box entities
  # test_draw_Cylinder entities
  # test_draw_Tubs entities
  # test_draw_Polycone_2pi entities
  # test_draw_Polycone entities
  # test_draw_Polycone_BeamVacuum5 entities
  # test_draw_CALO entities
  # test_draw_UnionSolid entities
  # test_draw_SubtractionSolid entities
  # test_draw_Torus entities
  test_draw_Polyhedra entities
end

##____________________________________________________________________________||

test_draw_solids
