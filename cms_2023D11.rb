# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

require File.dirname(__FILE__) + '/sitecfg.rb'

require 'gratr'

require 'buildGeometryManager'
require 'buildDDLCallBacks'
require 'readXMLFiles'
require 'PartBuilder'
require 'solids'
require 'graph_functions.rb'
require 'graph_functions_DD'
load 'PosPartExecuter.rb'
load 'LogicalPartInstance.rb'
load 'LogicalPartDefiner.rb'

##__________________________________________________________________||
def cmsmain

  read_xmlfiles
  # read_xmlfiles_from_cache

  draw_gratr

end

##__________________________________________________________________||
def draw_gratr


  # all PosParts in the XML file
  graphAll = GRATR::DirectedPseudoGraph.new
  $posPartsManager.parts.each { |pp| graphAll.add_edge!(pp.parentName, pp.childName, pp) }

  vertices = Hash[$logicalPartsManager.parts.map { |p| [p.name, LogicalPartInstance.new($geometryManager, p)] } ]

  topName = :"cms:CMSE"

  nameDepthPhase1PixelBarrel = [
    {:name => :"pixel:Layer1", :depth => 2},
    {:name => :"pixel:Layer2", :depth => 2},
    {:name => :"pixel:Layer3", :depth => 2},
    {:name => :"pixel:Layer4", :depth => 2},
  ]

  nameDepthPhase2PixelEndcap = [
    {:name => :"pixel:Disc1",  :depth => 2},
    {:name => :"pixel:Disc2",  :depth => 2},
    {:name => :"pixel:Disc3",  :depth => 2},
    {:name => :"pixel:Disc4",  :depth => 2},
    {:name => :"pixel:Disc5",  :depth => 2},
    {:name => :"pixel:Disc6",  :depth => 2},
    {:name => :"pixel:Disc7",  :depth => 2},
    {:name => :"pixel:Disc8",  :depth => 2},
    {:name => :"pixel:Disc9",  :depth => 2},
    {:name => :"pixel:Disc10", :depth => 2},
    {:name => :"pixel:Disc11", :depth => 2},
    {:name => :"pixel:Disc12", :depth => 2},
  ]


  nameDepthPhase2OTBarrel = [
    {:name => :"tracker:Rod1", :depth => 1},
    {:name => :"tracker:Rod2", :depth => 1},
    {:name => :"tracker:Rod3", :depth => 1},
    {:name => :"tracker:Rod4", :depth => 1},
    {:name => :"tracker:Rod5", :depth => 1},
    {:name => :"tracker:Rod6", :depth => 1},
  ]

  nameDepthPhase2OTForward = [
    {:name => :"tracker:Disc1", :depth => 2},
    {:name => :"tracker:Disc2", :depth => 2},
    {:name => :"tracker:Disc3", :depth => 2},
    {:name => :"tracker:Disc4", :depth => 2},
    {:name => :"tracker:Disc5", :depth => 2},
  ]

  nameDepthEB = [
    {:name => :"eregalgo:EFAW", :depth => 0},
    {:name => :"eregalgo:EBCOOL1", :depth => 0},
    {:name => :"eregalgo:EBCOOL2", :depth => 0},
    {:name => :"eregalgo:EBCOOL3", :depth => 0},
    {:name => :"eregalgo:EBCOOL4", :depth => 0},
  ]

  nameDepthHB = [
    {:name => :"hcalbarrelalgo:HBModule", :depth => 1},
  ]

  nameDepthHE = [
    {:name => :"hcalendcapalgo:HE", :depth => 3},
  ]

  nameDepthHGCAL = [
    {:name => :"hgcal:HGCal", :depth => 2},
  ]

  nameDepthHF = [
    {:name => :"hcalforwardalgo:VCAL", :depth => 2},
  ]

  nameDepthMB = [
    {:name => :"hcalouteralgo:HTP1C_T1", :depth => 0},
    {:name => :"hcalouteralgo:HTP1C_T2", :depth => 0},
    {:name => :"hcalouteralgo:HTP1C_T3", :depth => 0},
    {:name => :"hcalouteralgo:HTP1C_T4", :depth => 0},
    {:name => :"hcalouteralgo:HTP1C_T5", :depth => 0},
    {:name => :"hcalouteralgo:HTP1C_T6", :depth => 0},
    {:name => :"hcalouteralgo:HTP1_T1", :depth => 0},
    {:name => :"hcalouteralgo:HTP1_T2", :depth => 0},
    {:name => :"hcalouteralgo:HTP1_T3", :depth => 0},
    {:name => :"hcalouteralgo:HTP1_T3_S", :depth => 0},
    {:name => :"hcalouteralgo:HTP1_T4", :depth => 0},
    {:name => :"hcalouteralgo:HTP1_T4_S", :depth => 0},
    {:name => :"hcalouteralgo:HTP1_T5", :depth => 0},
    {:name => :"hcalouteralgo:HTP1_T5_S", :depth => 0},
    {:name => :"hcalouteralgo:HTP1_T6", :depth => 0},
    {:name => :"hcalouteralgo:HTP1_T6_S", :depth => 0},
    {:name => :"hcalouteralgo:HTP0_T1", :depth => 0},
    {:name => :"hcalouteralgo:HTP0_T2", :depth => 0},
    {:name => :"hcalouteralgo:HTP0_T3", :depth => 0},
    {:name => :"hcalouteralgo:HTP0_T4", :depth => 0},
    {:name => :"hcalouteralgo:HTP0_T5", :depth => 0},
    {:name => :"hcalouteralgo:HTP0_T6", :depth => 0},
    {:name => :"hcalouteralgo:MBTail", :depth => 0},
    {:name => :"mb1:MB1ChimN", :depth => 1},
    {:name => :"mb1:MB1ChimP", :depth => 1},
    {:name => :"mb1:MB1N", :depth => 1},
    {:name => :"mb1:MB1N0P", :depth => 1},
    {:name => :"mb1:MB1P", :depth => 1},
    {:name => :"mb1:MB1P0", :depth => 1},
    {:name => :"mb2:MB2ChimN", :depth => 1},
    {:name => :"mb2:MB2ChimP", :depth => 1},
    {:name => :"mb2:MB2N23N", :depth => 1},
    {:name => :"mb2:MB2N32N", :depth => 1},
    {:name => :"mb2:MB2N32P", :depth => 1},
    {:name => :"mb2:MB2P23P", :depth => 1},
    {:name => :"mb2:MB2P32P", :depth => 1},
    {:name => :"mb3:MB3ChimN", :depth => 1},
    {:name => :"mb3:MB3ChimP", :depth => 1},
    {:name => :"mb3:MB3N", :depth => 1},
    {:name => :"mb3:MB3P", :depth => 1},
    {:name => :"mb4:MB4BigChimN", :depth => 1},
    {:name => :"mb4:MB4BigLeftN", :depth => 1},
    {:name => :"mb4:MB4BigLeftP", :depth => 1},
    {:name => :"mb4:MB4BigRightN", :depth => 1},
    {:name => :"mb4:MB4BigRightP", :depth => 1},
    {:name => :"mb4:MB4BottomLeftN", :depth => 1},
    {:name => :"mb4:MB4BottomLeftP", :depth => 1},
    {:name => :"mb4:MB4BottomRightN", :depth => 1},
    {:name => :"mb4:MB4BottomRightP", :depth => 1},
    {:name => :"mb4:MB4FeetN", :depth => 1},
    {:name => :"mb4:MB4FeetP", :depth => 1},
    {:name => :"mb4:MB4SmallLeftN", :depth => 1},
    {:name => :"mb4:MB4SmallLeftP", :depth => 1},
    {:name => :"mb4:MB4SmallRightN", :depth => 1},
    {:name => :"mb4:MB4SmallRightP", :depth => 1},
    {:name => :"mb4:MB4TopChimP", :depth => 1},
    {:name => :"mb4:MB4TopN", :depth => 1},
    {:name => :"mb4:MB4TopP", :depth => 1},
    {:name => :"muonYoke:YB1Chim_w1N_b3", :depth => 0},
    {:name => :"muonYoke:YB1Chim_w1N_b5", :depth => 0},
    {:name => :"muonYoke:YB1Chim_w1N_m2", :depth => 0},
    {:name => :"muonYoke:YB1Chim_w1N_m3", :depth => 0},
    {:name => :"muonYoke:YB1Chim_w1N_m4", :depth => 0},
    {:name => :"muonYoke:YB1Chim_w1P_m3", :depth => 0},
    {:name => :"muonYoke:YB1_w0_b1", :depth => 0},
    {:name => :"muonYoke:YB1_w0_b2", :depth => 0},
    {:name => :"muonYoke:YB1_w0_b3", :depth => 0},
    {:name => :"muonYoke:YB1_w0_b4", :depth => 0},
    {:name => :"muonYoke:YB1_w0_b5", :depth => 0},
    {:name => :"muonYoke:YB1_w0_m1", :depth => 0},
    {:name => :"muonYoke:YB1_w0_m2", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_b1", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_b2", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_b3", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_b4", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_b5", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_b6", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_b7", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_b8", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_m1", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_m2", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_m3", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_m4", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_m5", :depth => 0},
    {:name => :"muonYoke:YB1_w1N_m6", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_b1", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_b2", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_b3", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_b4", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_b5", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_b6", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_b7", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_b8", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_m1", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_m2", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_m3", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_m4", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_m5", :depth => 0},
    {:name => :"muonYoke:YB1_w1P_m6", :depth => 0},
    {:name => :"muonYoke:YB1_w2N_b1", :depth => 0},
    {:name => :"muonYoke:YB1_w2N_b2", :depth => 0},
    {:name => :"muonYoke:YB1_w2N_b3", :depth => 0},
    {:name => :"muonYoke:YB1_w2N_m1", :depth => 0},
    {:name => :"muonYoke:YB1_w2P_b1", :depth => 0},
    {:name => :"muonYoke:YB1_w2P_b2", :depth => 0},
    {:name => :"muonYoke:YB1_w2P_b3", :depth => 0},
    {:name => :"muonYoke:YB1_w2P_m1", :depth => 0},
    {:name => :"muonYoke:YB2Chim_w1N_b3", :depth => 0},
    {:name => :"muonYoke:YB2Chim_w1N_b5", :depth => 0},
    {:name => :"muonYoke:YB2Chim_w1N_m2", :depth => 0},
    {:name => :"muonYoke:YB2Chim_w1N_m3", :depth => 0},
    {:name => :"muonYoke:YB2Chim_w1N_m4", :depth => 0},
    {:name => :"muonYoke:YB2Chim_w1N_t3", :depth => 0},
    {:name => :"muonYoke:YB2Chim_w1N_t5", :depth => 0},
    {:name => :"muonYoke:YB2Chim_w1P_m3", :depth => 0},
    {:name => :"muonYoke:YB2_w0_b1", :depth => 0},
    {:name => :"muonYoke:YB2_w0_b2", :depth => 0},
    {:name => :"muonYoke:YB2_w0_b3", :depth => 0},
    {:name => :"muonYoke:YB2_w0_b4", :depth => 0},
    {:name => :"muonYoke:YB2_w0_b5", :depth => 0},
    {:name => :"muonYoke:YB2_w0_b6", :depth => 0},
    {:name => :"muonYoke:YB2_w0_m1", :depth => 0},
    {:name => :"muonYoke:YB2_w0_m2", :depth => 0},
    {:name => :"muonYoke:YB2_w0_t1", :depth => 0},
    {:name => :"muonYoke:YB2_w0_t2", :depth => 0},
    {:name => :"muonYoke:YB2_w0_t3", :depth => 0},
    {:name => :"muonYoke:YB2_w0_t4", :depth => 0},
    {:name => :"muonYoke:YB2_w0_t5", :depth => 0},
    {:name => :"muonYoke:YB2_w0_t6", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_b1", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_b2", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_b3", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_b4", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_b5", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_b6", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_b7", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_b8", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_m1", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_m2", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_m3", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_m4", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_m5", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_m6", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_t1", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_t2", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_t3", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_t4", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_t5", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_t6", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_t7", :depth => 0},
    {:name => :"muonYoke:YB2_w1N_t8", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_b1", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_b2", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_b3", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_b4", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_b5", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_b6", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_b7", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_b8", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_m1", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_m2", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_m3", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_m4", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_m5", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_m6", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_t1", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_t2", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_t3", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_t4", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_t5", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_t6", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_t7", :depth => 0},
    {:name => :"muonYoke:YB2_w1P_t8", :depth => 0},
    {:name => :"muonYoke:YB2_w2N_b1", :depth => 0},
    {:name => :"muonYoke:YB2_w2N_b2", :depth => 0},
    {:name => :"muonYoke:YB2_w2N_b3", :depth => 0},
    {:name => :"muonYoke:YB2_w2N_m1", :depth => 0},
    {:name => :"muonYoke:YB2_w2N_t1", :depth => 0},
    {:name => :"muonYoke:YB2_w2N_t2", :depth => 0},
    {:name => :"muonYoke:YB2_w2N_t3", :depth => 0},
    {:name => :"muonYoke:YB2_w2P_b1", :depth => 0},
    {:name => :"muonYoke:YB2_w2P_b2", :depth => 0},
    {:name => :"muonYoke:YB2_w2P_b3", :depth => 0},
    {:name => :"muonYoke:YB2_w2P_m1", :depth => 0},
    {:name => :"muonYoke:YB2_w2P_t1", :depth => 0},
    {:name => :"muonYoke:YB2_w2P_t2", :depth => 0},
    {:name => :"muonYoke:YB2_w2P_t3", :depth => 0},
    {:name => :"muonYoke:YB3Chim_w1N_b3", :depth => 0},
    {:name => :"muonYoke:YB3Chim_w1N_b5", :depth => 0},
    {:name => :"muonYoke:YB3Chim_w1N_m2", :depth => 0},
    {:name => :"muonYoke:YB3Chim_w1N_m3", :depth => 0},
    {:name => :"muonYoke:YB3Chim_w1N_m4", :depth => 0},
    {:name => :"muonYoke:YB3Chim_w1N_t3", :depth => 0},
    {:name => :"muonYoke:YB3Chim_w1N_t5", :depth => 0},
    {:name => :"muonYoke:YB3Chim_w1P_m3", :depth => 0},
    {:name => :"muonYoke:YB3_w0_b1", :depth => 0},
    {:name => :"muonYoke:YB3_w0_b2", :depth => 0},
    {:name => :"muonYoke:YB3_w0_b3", :depth => 0},
    {:name => :"muonYoke:YB3_w0_b4", :depth => 0},
    {:name => :"muonYoke:YB3_w0_b5", :depth => 0},
    {:name => :"muonYoke:YB3_w0_b6", :depth => 0},
    {:name => :"muonYoke:YB3_w0_m1", :depth => 0},
    {:name => :"muonYoke:YB3_w0_m2", :depth => 0},
    {:name => :"muonYoke:YB3_w0_t1", :depth => 0},
    {:name => :"muonYoke:YB3_w0_t2", :depth => 0},
    {:name => :"muonYoke:YB3_w0_t3", :depth => 0},
    {:name => :"muonYoke:YB3_w0_t4", :depth => 0},
    {:name => :"muonYoke:YB3_w0_t5", :depth => 0},
    {:name => :"muonYoke:YB3_w0_t6", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_b1", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_b2", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_b3", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_b4", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_b5", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_b6", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_b7", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_b8", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_m1", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_m2", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_m3", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_m4", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_m5", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_m6", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_t1", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_t2", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_t3", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_t4", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_t5", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_t6", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_t7", :depth => 0},
    {:name => :"muonYoke:YB3_w1N_t8", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_b1", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_b2", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_b3", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_b4", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_b5", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_b6", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_b7", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_b8", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_m1", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_m2", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_m3", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_m4", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_m5", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_m6", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_t1", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_t2", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_t3", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_t4", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_t5", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_t6", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_t7", :depth => 0},
    {:name => :"muonYoke:YB3_w1P_t8", :depth => 0},
    {:name => :"muonYoke:YB3_w2N_b1", :depth => 0},
    {:name => :"muonYoke:YB3_w2N_b2", :depth => 0},
    {:name => :"muonYoke:YB3_w2N_b3", :depth => 0},
    {:name => :"muonYoke:YB3_w2N_m1", :depth => 0},
    {:name => :"muonYoke:YB3_w2N_t1", :depth => 0},
    {:name => :"muonYoke:YB3_w2N_t2", :depth => 0},
    {:name => :"muonYoke:YB3_w2N_t3", :depth => 0},
    {:name => :"muonYoke:YB3_w2P_b1", :depth => 0},
    {:name => :"muonYoke:YB3_w2P_b2", :depth => 0},
    {:name => :"muonYoke:YB3_w2P_b3", :depth => 0},
    {:name => :"muonYoke:YB3_w2P_m1", :depth => 0},
    {:name => :"muonYoke:YB3_w2P_t1", :depth => 0},
    {:name => :"muonYoke:YB3_w2P_t2", :depth => 0},
    {:name => :"muonYoke:YB3_w2P_t3", :depth => 0},
    {:name => :"muonYoke:YBSepar2_w0_1", :depth => 0},
    {:name => :"muonYoke:YBSepar2_w0_2", :depth => 0},
    {:name => :"muonYoke:YBSepar2_w1N", :depth => 0},
    {:name => :"muonYoke:YBSepar2_w1P", :depth => 0},
    {:name => :"muonYoke:YBSepar2_w2N", :depth => 0},
    {:name => :"muonYoke:YBSepar2_w2P", :depth => 0},
    {:name => :"muonYoke:YBSepar3_w0_1", :depth => 0},
    {:name => :"muonYoke:YBSepar3_w0_2", :depth => 0},
    {:name => :"muonYoke:YBSepar3_w1N", :depth => 0},
    {:name => :"muonYoke:YBSepar3_w1P", :depth => 0},
    {:name => :"muonYoke:YBSepar3_w2N", :depth => 0},
    {:name => :"muonYoke:YBSepar3_w2P", :depth => 0},
    {:name => :"muonYoke:YBSepar_1", :depth => 0},
  ]

  nameDepthME = [
    {:name => :"mf:MEP", :depth => 3},
    {:name => :"mf:MEN", :depth => 3},
  ]

  nameDepthMGNT = [
    {:name => :"mgnt:MGNT", :depth => 0},
  ]

  nameDepthTracker = nameDepthPhase2OTBarrel + nameDepthPhase2OTForward + nameDepthPhase1PixelBarrel + nameDepthPhase2PixelEndcap

  nameDepthECAL = nameDepthEB
  nameDepthHCAL = nameDepthHB + nameDepthHE + nameDepthHF
  nameDepthCALO = nameDepthHCAL + nameDepthECAL + nameDepthHGCAL

  nameDepthMUON = nameDepthMB + nameDepthME + nameDepthMGNT

  nameDepthBEAM = [
    {:name => :"beampipe:BEAM", :depth => 1},
    {:name => :"beampipe:BEAM1", :depth => 1},
    {:name => :"beampipe:BEAM2", :depth => 1},
    {:name => :"beampipe:BEAM3", :depth => 1},
  ]

  nameDepthOQUA = [
    {:name => :"forwardshield:OQUA", :depth => 1},
  ]

  nameDepthList = nameDepthOQUA + nameDepthBEAM + nameDepthMUON + nameDepthCALO + nameDepthTracker

  posPartNames = $posPartsManager.parts.collect { |pp| [pp.parentName, pp.childName] }.flatten(1).uniq
  unknownNames = nameDepthList.select { |e| not posPartNames.include? e[:name] }.collect { |e| e[:name] }
  puts "cannot find #{unknownNames} in PosPartSection" unless unknownNames.empty?
  nameDepthList = nameDepthList.select { |e| not unknownNames.include? e[:name] }

  names = nameDepthList.collect { |e| e[:name] }

  graphTopToNames = subgraph_from_to(graphAll, topName, names)

  graphNamesToDepths = graphAll.class.new
  nameDepthList.each do |e|
    graphNamesToDepths = graphNamesToDepths + subgraph_from_depth(graphAll, e[:name], e[:depth])
  end

  graph = graphTopToNames + graphNamesToDepths

  draw_array graph, vertices, topName

end

##__________________________________________________________________||
def draw_array graph, vertexLabel, topName

  Sketchup.active_model.definitions.purge_unused
  start_time = Time.now
  Sketchup.active_model.start_operation("Draw CMS", true)

  posPartExecuter = PosPartExecuter.new $geometryManager


  graph.edges.each do |edge|
    posPart = edge.label
    posPartExecuter.exec posPart, vertexLabel[edge.source], vertexLabel[edge.target]
  end

  graph.topsort.reverse.each do |v|
    logicalPart = vertexLabel[v]
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /Air$/
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /free_space$/
    logicalPart.placeSolid()
  end

  # $logicalPartsManager.get(topName).placeSolid()

  graph.topsort.reverse.each do |v|
    logicalPart = vertexLabel[v]
    logicalPart.define()
  end

  lp = vertexLabel[topName.to_sym]
  definition = lp.definition
  if definition
    entities = Sketchup.active_model.entities
    transform = Geom::Transformation.new(Geom::Point3d.new(0, 0, 15.m))
    solidInstance = entities.add_instance definition, transform
  end

  Sketchup.active_model.commit_operation
  end_time = Time.now
  puts "Time elapsed #{(end_time - start_time)*1000} milliseconds"


end

##__________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__)) + '/'
  xmlfileListTest = [
    'GeometryExtended2023D11.xml'
                    ]

  xmlfileList = xmlfileListTest

  xmlfileList.map! {|f| f = topDir + f }

  p xmlfileList

  geometryManager = buildGeometryManager()
  callBacks = buildDDLCallBacks(geometryManager)
  readXMLFiles(xmlfileList, callBacks)
end

##__________________________________________________________________||
def read_xmlfiles_from_cache
  fillGeometryManager($geometryManager)
  $geometryManager.reload_from_cache
end

##__________________________________________________________________||

cmsmain
