#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

$LOAD_PATH.push(File.join(File.dirname(File.dirname(__FILE__)), 'gratr', 'lib'))

require 'test/unit'
require "stringio"
require "graph_functions"

require 'gratr'

##__________________________________________________________________||
class Test_graph_functions < Test::Unit::TestCase

  def setup
    @graph = GRATR::DirectedPseudoGraph[1,2, 1,2, 1,3, 2,4, 2,4, 2,4, 2,5, 3,6, 3,7, 3,7]
    #            1
    #         //    \
    #        2       3
    #     /// \     / \\
    #      4   5   6   7

    @graph2 = GRATR::DirectedPseudoGraph[0,1, 1,2, 1,2, 1,3, 2,4, 2,4, 2,4, 2,5, 3,6, 3,7, 3,7, 5,8, 5,8, 6,8, 6,8]
    #            0
    #            |
    #            1
    #         //    \
    #        2       3
    #     /// \     / \\
    #      4   5   6   7
    #          \\//
    #            8

    @graph3 = GRATR::DirectedPseudoGraph[1,2, 1,2, 1,3, 2,4, 2,4, 2,4, 2,5, 3,6, 3,7, 3,7, 5,8, 5,8, 6,8, 6,8, 6,9, 8,10, 9,11]
    #            1
    #         //    \
    #        2       3
    #     /// \     / \\
    #      4   5   6   7
    #          \\//\
    #            8  9
    #           /    \
    #          10     11
  end

  def test_basics
    assert_equal 10, @graph.edges.size
    assert_equal 7, @graph.size
    assert_equal 10, @graph.num_edges
    assert_equal 7, @graph.num_vertices
    assert @graph.oriented?
  end

  def test_subgraph_from
    sub = subgraph_from(@graph, 2)
    #        2
    #     /// \
    #      4   5
    assert_equal @graph.class, sub.class
    assert_equal [2, 4, 5], sub.vertices.sort
    assert_equal 4, sub.num_edges
    assert sub.edge?(2,4)
    assert sub.edge?(2,5)
  end

  def test_subgraph_from_to
    sub = subgraph_from_to(@graph2, 0, [8])
    #            0
    #            |
    #            1
    #         //    \
    #        2       3
    #         \     /
    #          5   6
    #          \\//
    #            8
    assert_equal @graph2.class, sub.class
    assert_equal [0, 1, 2, 3, 5, 6, 8], sub.vertices.sort
    assert_equal 10, sub.num_edges
  end

  def test_subgraph_from_depth
    sub = subgraph_from_depth(@graph3, 3, 2)
    #                3
    #               / \\
    #              6   7
    #            //\
    #            8  9
    assert_equal @graph3.class, sub.class
    assert_equal [3, 6, 7, 8, 9], sub.vertices.sort
    assert_equal 6, sub.num_edges
  end

end

##__________________________________________________________________||
