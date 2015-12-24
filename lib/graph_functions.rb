#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

##__________________________________________________________________||
# Returns a subgraph of `graph` which starts from `from`.
def subgraph_from(graph, from)

  # e.g.,
  # graph = GRATR::DirectedPseudoGraph[0,1, 1,2, 1,2, 1,3, 2,4, 2,5,
  #                                    2,5, 3,6, 3,7, 5,8, 6,8, 6,9]
  #            0
  #            |
  #            1
  #         //    \
  #        2       3
  #       / \\    / \
  #      4   5   6   7
  #           \ /\   
  #            8  9
  #
  # from = 2

  hash_bfs = graph.bfs_tree_from_vertex(from)
  # e.g., hash_bfs = {4=>2, 5=>2, 8=>5}
  
  vertices = Set.new hash_bfs.flatten
  # e.g., vertices = <Set: {4, 2, 5, 8}>

  edges = graph.edges.select { |e| vertices.include?(e.source) and vertices.include?(e.target) }
  # e.g., edges = [(2-4), (2-5), (2-5), (5-8)]

  ret = graph.class.new
  edges.each { |e| ret.add_edge!(e) }

  # ret:
  #        2
  #       / \\
  #      4   5
  #           \
  #            8
  #

  ret
end

##__________________________________________________________________||
# Returns a subgraph of `graph` which starts from `from` and has a
# depth of `depth`.
def subgraph_from_depth(graph, from, depth)

  # e.g.,
  # graph = GRATR::DirectedPseudoGraph[0,1, 1,2, 1,2, 1,3, 2,4, 2,5,
  #                                    2,5, 3,6, 3,7, 5,8, 6,8, 6,9]
  #            0
  #            |
  #            1
  #         //    \
  #        2       3
  #       / \\    / \
  #      4   5   6   7
  #           \ /\
  #            8  9
  #
  # from = 1
  # depth = 2

  def buildEdgeList graph, from, depth
    return [ ] if depth == 0
    to_list = graph.adjacent(from, {:direction => :out}).uniq
    ret = Set.new
    ret.merge(to_list.map { |to| [from, to] })
    to_list.each do |to|
      ret.merge(buildEdgeList graph, to, depth - 1)
    end
    ret
  end
  edges = buildEdgeList graph, from, depth

  ret = graph.class.new
  graph.edges.each { |e| ret.add_edge!(e) if edges.include?([e.source, e.target]) }

  #
  #            1
  #         //    \
  #        2       3
  #       / \\    / \
  #      4   5   6   7
  #
  ret
end

##__________________________________________________________________||
def subgraph_from_to(graph, from, to)
  def buildEdgeList graph, from, to
    to.reject! { |t| t == from }
    ret = Set.new
    to.each do |child|
      parents = graph.adjacent(child, {:direction => :in})
      ret.merge(parents.map { |parent| [parent, child] })
      ret.merge(buildEdgeList(graph, from, parents))
    end
    ret
  end
  edges = buildEdgeList graph, from, to
  ret = graph.class.new
  graph.edges.each { |e| ret.add_edge!(e) if edges.include?([e.source, e.target]) }
  ret
end

##__________________________________________________________________||
