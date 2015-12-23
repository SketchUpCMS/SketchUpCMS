#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>


##__________________________________________________________________||
def subgraph_from(graph, from)
  # tree from from
  hashPredecessorBFSTreeFrom = graph.bfs_tree_from_vertex(from)
  arrayBFSTreeFrom = hashPredecessorBFSTreeFrom.collect { |k, v| k }.uniq
  arrayBFSTreeFrom << from

  graphFrom = graph.class.new
  graph.edges.each { |a| graphFrom.add_edge!(a) if arrayBFSTreeFrom.include?(a.source) and arrayBFSTreeFrom.include?(a.target) }

  graphFrom
end

##__________________________________________________________________||
def subgraph_from_depth(graph, from, depth = -1)

  graphFrom = subgraph_from(graph, from)
  return graphFrom if depth < 0

  simple_weight = Proc.new {|e| 1}
  distance, path = graphFrom.shortest_path(from, simple_weight)

  graphFromDepth = graph.class.new
  graphFrom.edges.each { |a| graphFromDepth.add_edge!(a) if distance[a.target] <= depth }
  graphFromDepth
end

##__________________________________________________________________||
def subgraph_from_to(graph, from, to)
  def buildEdgeList graph, edges, from, to
    to.each do |child|
      parents = graph.adjacent(child, {:direction => :in})
      parents.each do |parent|
        edges.push([parent, child])
      end
      parents.reject! { |p| p == from }
      buildEdgeList(graph, edges, from, parents)
    end
    edges
  end
  edges = [ ]
  edges = buildEdgeList graph, edges, from, to
  ret = graph.class.new
  graph.edges.each { |e| ret.add_edge!(e) if edges.include?([e.source, e.target]) }
  ret
end

##__________________________________________________________________||
def topsort_from_depth(graph, from, depth = -1)
  graphFrom = subgraph_from_depth(graph, from, depth)

  # topological sort from from
  graphFrom.size > 0 ? graphFrom.topsort(from) : [from]
end

##__________________________________________________________________||
def topsort_from_to graph, from, to
  localGraph = subgraph_from_to(graph, from, to)
  localGraph.size > 0 ? localGraph.topsort(from) : [from]
end

##__________________________________________________________________||
