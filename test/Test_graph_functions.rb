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

    @graph_2 = GRATR::DirectedPseudoGraph[0,1,
                                          1,2, 1,2, 1,3, 1,6,
                                          2,4, 2,5, 2,5,
                                          3,7,
                                          5,8,
                                          6,8, 6,9,
                                         ]
    #            0
    #            |
    #            1
    #         // |  \
    #        2   |   3
    #       / \\  \   \
    #      4   5   6   7
    #           \ / \
    #            8   9

  end

  def test_basics
    # @graph_0.write_to_graphic_file('pdf','graph')
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
    assert_not_same @graph_0, sub
    assert_equal [2, 4, 5, 8, 10], sub.vertices.sort
    assert_equal 8, sub.num_edges
    assert sub.edge?(2,4)
    assert sub.edge?(2,5)
    assert sub.edge?(5,8)
    assert sub.edge?(8,10)
    assert_equal [[2, 4], [2, 4], [2, 5], [2, 5], [2, 5], [5, 8], [5, 8], [8, 10]], sub.edges.map { |e| [e.source, e.target] }.sort
  end

  def test_subgraph_from__array
    sub = subgraph_from(@graph_0, [2, 6])
    #        2
    #      //\\\
    #      4   5   6
    #          \\//\
    #            8  9
    #           /    \
    #          10     11

    assert_equal @graph_0.class, sub.class
    assert_equal [[2, 4], [2, 4], [2, 5], [2, 5], [2, 5],
                  [5, 8], [5, 8], [6, 8], [6, 8], [6, 9],
                  [8, 10], [9, 11]], sub.edges.map { |e| [e.source, e.target] }.sort
  end

  def test_subgraph_from_to__simple
    sub = subgraph_from_to(@graph_0, 0, 8)
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
    assert_not_same @graph_0, sub
    assert_equal [0, 1, 2, 3, 5, 6, 8], sub.vertices.sort
    assert_equal 12, sub.num_edges
    assert_equal [[0, 1], [1, 2], [1, 2], [1, 3], [2, 5], [2, 5], [2, 5], [3, 6], [5, 8], [5, 8], [6, 8], [6, 8]], sub.edges.map { |e| [e.source, e.target] }.sort
  end

  def test_subgraph_from_to__simple_02
    sub = subgraph_from_to(@graph_0, 2, 8)
    #        2
    #        \\\
    #          5
    #          \\
    #            8
    assert_equal @graph_0.class, sub.class
    assert_equal [[2, 5], [2, 5], [2, 5], [5, 8], [5, 8]], sub.edges.map { |e| [e.source, e.target] }.sort
  end

  def test_subgraph_from_to__to_array
    sub = subgraph_from_to(@graph_0, 1, [10, 7])
    #            1
    #         //     \
    #        2         3
    #        \\\    /  ||
    #          5   6   7
    #          \\//
    #            8
    #           /
    #          10
    assert_equal @graph_0.class, sub.class
    assert_equal [[1, 2], [1, 2], [1, 3], [2, 5], [2, 5], [2, 5], [3, 6], [3, 7], [3, 7], [5, 8], [5, 8], [6, 8], [6, 8], [8, 10]], sub.edges.map { |e| [e.source, e.target] }.sort
  end


  def test_subgraph_from_to__from_array__to_array
    sub = subgraph_from_to(@graph_0, [2, 3], [10, 13])
    # sub.write_to_graphic_file('pdf', 'graph')
    #        2         3
    #        \\\    /  ||  \\
    #          5   6   7    12
    #          \\//     \  /
    #            8       13
    #           /
    #          10
    assert_equal @graph_0.class, sub.class
    assert_equal [[2, 5], [2, 5], [2, 5],
                  [3, 6], [3, 7], [3, 7], [3, 12], [3, 12],
                  [5, 8], [5, 8], [6, 8], [6, 8],
                  [7, 13], [8, 10], [12, 13]], sub.edges.map { |e| [e.source, e.target] }.sort

  end

  def test_subgraph_from_depth__simple
    sub = subgraph_from_depth(@graph_0, 3, 2)
    #                  3
    #               /  ||  \\
    #              6   7    12
    #            //\    \  /
    #            8  9    13
    assert_equal @graph_0.class, sub.class
    assert_not_same @graph_0, sub
    assert_equal [3, 6, 7, 8, 9, 12, 13], sub.vertices.sort
    assert_equal 10, sub.num_edges
    assert_equal [[3, 6], [3, 7], [3, 7], [3, 12], [3, 12], [6, 8], [6, 8], [6, 9], [7, 13], [12, 13]], sub.edges.map { |e| [e.source, e.target] }.sort
  end

  def test_subgraph_from_depth__disconnected_edges
    sub = subgraph_from_depth(@graph_2, 1, 2)
    #            1
    #         // |  \
    #        2   |   3
    #       / \\  \   \
    #      4   5   6   7
    #             / \
    #            8   9
    assert_equal @graph_2.class, sub.class
    assert_equal [[1, 2], [1, 2], [2, 4], [2, 5], [2, 5], [1, 3], [3, 7], [1, 6], [6, 8], [6, 9]].sort, sub.edges.map { |e| [e.source, e.target] }.sort
  end

  def test_subgraph_from_depth__depth_zero
    sub = subgraph_from_depth(@graph_1, 3, 0)
    assert_equal @graph_1.class, sub.class
    assert_equal [3], sub.vertices
  end

  def test_subgraph_from_depth__nonexistent_from
    sub = subgraph_from_depth(@graph_1, 35, 2)
    assert_equal @graph_1.class, sub.class
    assert_equal [ ], sub.edges.map { |e| [e.source, e.target] }.sort
  end

  def test_subgraph_from_depth__depth_negative
    sub = subgraph_from_depth(@graph_1, 3, -1)
    assert_equal @graph_1.class, sub.class
    assert_equal [ ], sub.edges.map { |e| [e.source, e.target] }.sort
  end

  def test_subgraph_trim_depth__depth_0
    sub = subgraph_trim_depth(@graph_0, 5, 0)
    # sub.write_to_graphic_file('pdf', 'graph_0')
    #            0
    #            |
    #            1
    #         //     \
    #        2         3
    #      //       /  ||  \\
    #      4       6   7    12
    #            //\    \  /
    #            8  9    13
    #           /    \
    #          10     11
    assert_equal @graph_0.class, sub.class
    assert_not_same @graph_0, sub
    assert_equal [[0, 1], [1, 2], [1, 2], [1, 3],
                  [2, 4], [2, 4],
                  [3, 6], [3, 7], [3, 7], [3, 12], [3, 12],
                  [6, 8], [6, 8], [6, 9],
                  [7, 13],
                  [8, 10], [9, 11],
                  [12, 13]], sub.edges.map { |e| [e.source, e.target] }.sort
  end

  def test_subgraph_trim_depth__depth_1
    sub = subgraph_trim_depth(@graph_0, 5, 1)
    # sub.write_to_graphic_file('pdf', 'graph_1')
    #            0
    #            |
    #            1
    #         //     \
    #        2         3
    #      //\\\    /  ||  \\
    #      4   5   6   7    12
    #            //\    \  /
    #            8  9    13
    #           /    \
    #          10     11
    assert_equal @graph_0.class, sub.class
    assert_not_same @graph_0, sub
    assert_equal [[0, 1], [1, 2], [1, 2], [1, 3],
                  [2, 4], [2, 4], [2, 5], [2, 5], [2, 5],
                  [3, 6], [3, 7], [3, 7], [3, 12], [3, 12],
                  [6, 8], [6, 8], [6, 9],
                  [7, 13], [8, 10],
                  [9, 11], [12, 13]], sub.edges.map { |e| [e.source, e.target] }.sort
  end

  def test_subgraph_trim_depth__depth_2
    sub = subgraph_trim_depth(@graph_0, 5, 2)
    # sub.write_to_graphic_file('pdf', 'graph_2')
    #            0
    #            |
    #            1
    #         //     \
    #        2         3
    #      //\\\    /  ||  \\
    #      4   5   6   7    12
    #          \\//\    \  /
    #            8  9    13
    #                \
    #                 11
    assert_equal @graph_0.class, sub.class
    assert_not_same @graph_0, sub
    assert_equal [[0, 1], [1, 2], [1, 2], [1, 3],
                  [2, 4], [2, 4], [2, 5], [2, 5], [2, 5],
                  [3, 6], [3, 7], [3, 7], [3, 12], [3, 12],
                  [5, 8], [5, 8], [6, 8], [6, 8], [6, 9], [7, 13],
                  [9, 11], [12, 13]], sub.edges.map { |e| [e.source, e.target] }.sort

  end

  def test_n_paths
    actual = n_paths(@graph_0, 0)
    assert_equal({0=>1, 1=>1,
                  2=>2, 3=>1,
                  4=>4, 5=>6, 6=>1, 7=>2,
                  8=>14, 9=>1,
                  10=>14, 11=>1,
                  12=>2, 13=>4}, actual)

  end

  def test_make_target_unique
    graph = @graph_0.class.new(@graph_0)

    edgeFrom2to5 = graph.edges.select { |e| e.source == 2 and e.target == 5 }[0]

    make_target_unique(graph, edgeFrom2to5, 51)

    assert_equal([[0, 1], [1, 2], [1, 2], [1, 3],
                  [2, 4], [2, 4], [2, 5], [2, 5], [2, 51],
                  [3, 6], [3, 7], [3, 7], [3, 12], [3, 12],
                  [5, 8], [5, 8],
                  [6, 8], [6, 8], [6, 9],
                  [7, 13], [8, 10], [9, 11], [12, 13],
                  [51, 8], [51, 8]], graph.edges.map { |e| [e.source, e.target] }.sort)


    # @graph_0.write_to_graphic_file('pdf','graph_0')
    # graph.write_to_graphic_file('pdf','graph')

  end


  def test_make_target_unique__array
    graph = @graph_0.class.new(@graph_0)

    edgesFrom2to5 = graph.edges.select { |e| e.source == 2 and e.target == 5 }[0, 2]

    make_target_unique(graph, edgesFrom2to5, 51)

    # @graph_0.write_to_graphic_file('pdf','graph_0')
    # graph.write_to_graphic_file('pdf','graph')

    assert_equal([[0, 1], [1, 2], [1, 2], [1, 3],
                  [2, 4], [2, 4], [2, 5], [2, 51], [2, 51],
                  [3, 6], [3, 7], [3, 7], [3, 12], [3, 12],
                  [5, 8], [5, 8],
                  [6, 8], [6, 8], [6, 9],
                  [7, 13], [8, 10], [9, 11], [12, 13],
                  [51, 8], [51, 8]], graph.edges.map { |e| [e.source, e.target] }.sort)


  end


end

##__________________________________________________________________||
