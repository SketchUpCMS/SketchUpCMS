# Tai Sakuma <sakuma@fnal.gov>
require 'sketchup'

require File.dirname(__FILE__) + '/sitecfg.rb'

require 'gratr'

require 'buildDDLCallBacks'
require 'readXMLFiles'
require 'PartBuilder'
require 'solids'
require 'GeometryManager'
require 'EntityDisplayer.rb'
require 'RotationsManager.rb'
require 'SolidsManager.rb'
require 'LogicalPartsManager.rb'
require 'PosPartsManager.rb'
require 'MaterialsManager.rb'
require 'defs.rb'

##____________________________________________________________________________||
def cmsmain

  read_xmlfiles
  # read_xmlfiles_from_cache

  draw_gratr_20120317_02

end

##____________________________________________________________________________||
def draw_gratr_20120317_02
  def create_array_to_draw graph, topName


    # GRATR::Digraph
    graphFromCMSE = subgraph_from(graph, topName)

    nameDepthMB = [ 
                   # {:name => :"hcalouteralgo:HTP1C_T1", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1C_T2", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1C_T3", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1C_T4", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1C_T5", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1C_T6", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1_T1", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1_T2", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1_T3", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1_T3_S", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1_T4", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1_T4_S", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1_T5", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1_T5_S", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1_T6", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP1_T6_S", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP0_T1", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP0_T2", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP0_T3", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP0_T4", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP0_T5", :depth => 0},
                   # {:name => :"hcalouteralgo:HTP0_T6", :depth => 0},
                   # {:name => :"hcalouteralgo:MBTail", :depth => 0},
                   {:name => :"mb1:MB1ChimN", :depth => 0},
                   {:name => :"mb1:MB1ChimP", :depth => 0},
                   {:name => :"mb1:MB1N", :depth => 0},
                   {:name => :"mb1:MB1N0P", :depth => 0},
                   {:name => :"mb1:MB1P", :depth => 0},
                   {:name => :"mb1:MB1P0", :depth => 0},
                   {:name => :"mb2:MB2ChimN", :depth => 0},
                   {:name => :"mb2:MB2ChimP", :depth => 0},
                   {:name => :"mb2:MB2N23N", :depth => 0},
                   {:name => :"mb2:MB2N32N", :depth => 0},
                   {:name => :"mb2:MB2N32P", :depth => 0},
                   {:name => :"mb2:MB2P23P", :depth => 0},
                   {:name => :"mb2:MB2P32P", :depth => 0},
                   {:name => :"mb3:MB3ChimN", :depth => 0},
                   {:name => :"mb3:MB3ChimP", :depth => 0},
                   {:name => :"mb3:MB3N", :depth => 0},
                   {:name => :"mb3:MB3P", :depth => 0},
                   {:name => :"mb4:MB4BigChimN", :depth => 0},
                   {:name => :"mb4:MB4BigLeftN", :depth => 0},
                   {:name => :"mb4:MB4BigLeftP", :depth => 0},
                   {:name => :"mb4:MB4BigRightN", :depth => 0},
                   {:name => :"mb4:MB4BigRightP", :depth => 0},
                   {:name => :"mb4:MB4BottomLeftN", :depth => 0},
                   {:name => :"mb4:MB4BottomLeftP", :depth => 0},
                   {:name => :"mb4:MB4BottomRightN", :depth => 0},
                   {:name => :"mb4:MB4BottomRightP", :depth => 0},
                   {:name => :"mb4:MB4FeetN", :depth => 0},
                   {:name => :"mb4:MB4FeetP", :depth => 0},
                   {:name => :"mb4:MB4SmallLeftN", :depth => 0},
                   {:name => :"mb4:MB4SmallLeftP", :depth => 0},
                   {:name => :"mb4:MB4SmallRightN", :depth => 0},
                   {:name => :"mb4:MB4SmallRightP", :depth => 0},
                   {:name => :"mb4:MB4TopChimP", :depth => 0},
                   {:name => :"mb4:MB4TopN", :depth => 0},
                   {:name => :"mb4:MB4TopP", :depth => 0},
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

    nameDepthList = nameDepthMB

    names = nameDepthList.collect { |e| e[:name] }
    graphFromCMSEToNames = subgraph_from_to(graphFromCMSE, topName, names)

    graphFromNames = GRATR::Digraph.new
    nameDepthList.each do |e|
      graphFromNames = graphFromNames + subgraph_from_depth(graphFromCMSE, e[:name], e[:depth])
    end

    graphToDraw = graphFromCMSEToNames + graphFromNames

    # e.g. [:"cms:CMSE", :"tracker:Tracker", :"tob:TOB", .. ]
    toDrawNames = graphToDraw.size > 0 ? graphToDraw.topsort(topName) : [topName]

    toDrawNames
  end

  # all PosParts in the XML file
  graphAll = GRATR::Digraph.new
  $posPartsManager.parts.each { |pp| graphAll.add_edge!(pp.parentName, pp.childName) }

  topName = :"cms:CMSE"
  arrayToDraw = create_array_to_draw graphAll, topName
  draw_array graphAll, arrayToDraw.reverse, topName
end

##____________________________________________________________________________||
def draw_array graph, arrayToDraw, topName

  Sketchup.active_model.definitions.purge_unused
  start_time = Time.now
  Sketchup.active_model.start_operation("Draw CMS", true)

  arrayToDraw.each do |parent|
    children = graph.neighborhood(parent, :out)
    children = children.select { |e| arrayToDraw.include?(e) }
    children.each do |child|
      posParts = $posPartsManager.getByParentChild(parent, child)
      posParts.each do |posPart|
        # puts "  exec posPart #{posPart.parentName} - #{posPart.childName}"
        posPart.exec
      end
    end
  end

  arrayToDraw.each do |v|
    logicalPart = $logicalPartsManager.get(v)
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /Air$/
    next if logicalPart.children.size > 0 and logicalPart.materialName.to_s =~ /free_space$/
    logicalPart.placeSolid()
  end

  $logicalPartsManager.get(topName).placeSolid()

  arrayToDraw.each do |v|
    logicalPart = $logicalPartsManager.get(v)
    logicalPart.define()
  end

  lp = $logicalPartsManager.get(topName.to_sym)
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

##____________________________________________________________________________||
def read_xmlfiles
  topDir = File.expand_path(File.dirname(__FILE__)) + '/'
  xmlfileListTest = [
                     'GeometryExtended.xml'
                    ]

  xmlfileList = xmlfileListTest

  xmlfileList.map! {|f| f = topDir + f }

  p xmlfileList

  geometryManager = buildGeometryManager()
  callBacks = buildDDLCallBacks(geometryManager)
  readXMLFiles(xmlfileList, callBacks, geometryManager)
end

##____________________________________________________________________________||
def read_xmlfiles_from_cache
  fillGeometryManager($geometryManager)
  $geometryManager.reload_from_cache
end

##____________________________________________________________________________||
def fillGeometryManager(geometryManager)

  $materialsManager = MaterialsManager.new
  $rotationsManager = RotationsManager.new
  $solidsManager = SolidsManager.new
  $logicalPartsManager = LogicalPartsManager.new
  $posPartsManager = PosPartsManager.new

  geometryManager.partBuilder = PartBuilder.new

  $solidsManager.entityDisplayer = EntityDisplayer.new('solids', 100.m, 0, 0)
  $logicalPartsManager.entityDisplayer = EntityDisplayer.new('logicalParts', -100.m, 0, 0)

  geometryManager = geometryManager
  geometryManager.materialsManager = $materialsManager
  geometryManager.rotationsManager = $rotationsManager
  geometryManager.solidsManager = $solidsManager
  geometryManager.logicalPartsManager = $logicalPartsManager
  geometryManager.posPartsManager = $posPartsManager

  $materialsManager.geometryManager = geometryManager
  $rotationsManager.geometryManager = geometryManager
  $solidsManager.geometryManager = geometryManager
  $logicalPartsManager.geometryManager = geometryManager
  $posPartsManager.geometryManager = geometryManager

  geometryManager
end

##____________________________________________________________________________||
def buildGeometryManager
  $geometryManager = GeometryManager.new
  fillGeometryManager($geometryManager)
  $geometryManager
end

##____________________________________________________________________________||

cmsmain
