#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

$LOAD_PATH.push(File.join(File.dirname(File.dirname(__FILE__)), 'gratr', 'lib'))

require 'test/unit'
require "graph_functions"

require 'gratr'
require 'gratr/dot'

##__________________________________________________________________||
class Test_graph_functions < Test::Unit::TestCase

  def setup
    @graph_0 = GRATR::DirectedPseudoGraph[0,1,
                                          1,2, 1,2, 1,3,
                                          2,4, 2,4, 2,5, 2,5, 2,5,
                                          3,6, 3,7, 3,7, 3,12, 3,12,
                                          5,8, 5,8,
                                          6,8, 6,8, 6,9,
                                          8,10,
                                          9,11,
                                          7,13,
                                          12,13
                                         ]
    #            0
    #            |
    #            1
    #         //     \
    #        2         3
    #      //\\\    /  ||  \\
    #      4   5   6   7    12
    #          \\//\    \  /
    #            8  9    13
    #           /    \
    #          10     11


    @graph_1 = GRATR::DirectedPseudoGraph[0,1,
                                          1,2, 1,2, 1,3,
                                          2,4, 2,5, 2,5,
                                          3,6, 3,7,
                                          5,8,
                                          6,8, 6,9,
                                         ]
    #            0
    #            |
    #            1
    #         //    \
    #        2       3
    #       / \\    / \
    #      4   5   6   7
    #           \ /\   
    #            8  9

  end

  def test_basics
    # @graph_0.write_to_graphic_file('jpg','visualize')
    assert_equal 23, @graph_0.edges.size
    assert_equal 14, @graph_0.size
    assert_equal 23, @graph_0.num_edges
    assert_equal 14, @graph_0.num_vertices
    assert @graph_0.oriented?
  end

  def test_subgraph_from
    sub = subgraph_from(@graph_0, 2)
    #        2
    #      //\\\
    #      4   5
    #          \\
    #            8
    #           /
    #          10
    assert_equal @graph_0.class, sub.class
    assert_equal [2, 4, 5, 8, 10], sub.vertices.sort
    assert_equal 8, sub.num_edges
    assert sub.edge?(2,4)
    assert sub.edge?(2,5)
    assert sub.edge?(5,8)
    assert sub.edge?(8,10)
  end

  def test_subgraph_from_depth
    sub = subgraph_from_depth(@graph_0, 3, 2)
    #                  3
    #               /  ||  \\
    #              6   7    12
    #            //\    \  /
    #            8  9    13
    assert_equal @graph_0.class, sub.class
    assert_equal [3, 6, 7, 8, 9, 12, 13], sub.vertices.sort
    assert_equal 10, sub.num_edges
  end

  def test_subgraph_from_to
    sub = subgraph_from_to(@graph_0, 0, [8])
    #            0
    #            |
    #            1
    #         //    \
    #        2       3
    #        \\\    /
    #          5   6
    #          \\//
    #            8
    assert_equal @graph_0.class, sub.class
    assert_equal [0, 1, 2, 3, 5, 6, 8], sub.vertices.sort
    assert_equal 12, sub.num_edges
  end

end

##__________________________________________________________________||
