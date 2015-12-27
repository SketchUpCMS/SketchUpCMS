#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

##__________________________________________________________________||
# Returns a subgraph of `graph` which starts from `from`.
# `from` can be an array
def subgraph_from(graph, from)

  from = [from] unless from.is_a?(Array)

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
  # from = [2, 6]

  vertices = Set.new

  from.each do |f|

    hash_bfs = graph.bfs_tree_from_vertex(f)
    # e.g., hash_bfs = {4=>2, 5=>2, 8=>5} when f = 2
  
    vertices.merge(hash_bfs.flatten)
    # e.g., vertices = <Set: {4, 2, 5, 8}> when f = 2

  end

  edges = graph.edges.select { |e| vertices.include?(e.source) and vertices.include?(e.target) }
  # e.g., edges = [(2-4), (2-5), (2-5), (5-8), (6-8), (6-9)]

  ret = graph.class.new
  edges.each { |e| ret.add_edge!(e) }

  # ret:
  #        2
  #       / \\
  #      4   5   6
  #           \ /\   
  #            8  9
  #

  ret
end

##__________________________________________________________________||
# Returns a subgraph of `graph` which starts from `from` and ends at
# `to`. `from` and `to` can be arrays
def subgraph_from_to(graph, from, to)

  graph = subgraph_from(graph, from)

  to = [to] unless to.is_a?(Array)

  def buildEdgeList graph, to
    ret = Set.new
    to.each do |child|
      parents = graph.adjacent(child, {:direction => :in})
      ret.merge(parents.map { |parent| [parent, child] })
      ret.merge(buildEdgeList(graph, parents))
    end
    ret
  end

  edges = buildEdgeList graph, to
  ret = graph.class.new
  graph.edges.each { |e| ret.add_edge!(e) if edges.include?([e.source, e.target]) }
  ret
end

##__________________________________________________________________||
# Returns a subgraph of `graph` which starts from `from` and has a
# depth of `depth`.
def subgraph_from_depth(graph, from, depth)

  ret = graph.class.new

  return ret if depth < 0

  return ret if ! graph.vertex?(from)

  if depth == 0
    ret.add_vertex! from
    return ret
  end

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
# Returns a hash in which the keys are vertices and the values are the
# numbers of all possible paths to the vertices from "from"
def n_paths(graph, from)
  counter = { from => 1 }
  graph.topsort.each do |v|
    next if v == from
    in_edges = graph.edges.select { |e| e.target == v && graph.adjacent(v, :direction => :in).include?(e.source) }
    counter[v] = in_edges.map { |e| counter[e.source] }.inject(:+)
  end
  counter
end

##__________________________________________________________________||
# Makes the target of the `edge` unique. Uses `vertex` as the unique
# vertex of the target.
def make_target_unique(graph, edge, vertex)
  graph.add_edge! edge.source, vertex, edge.label
  edgesFromTarget = graph.adjacent(edge.target, {:direction => :out, :type => :edges})
  edgesFromTarget.each do |e|
    graph.add_edge! vertex, e.target, e.label
  end
  graph.remove_edge! edge
  graph
end

##__________________________________________________________________||
