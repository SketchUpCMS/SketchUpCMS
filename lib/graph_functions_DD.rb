#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require "graph_functions"


# Graph functions for Detector Description (DD)

##__________________________________________________________________||
# Makes the logicalPart at the target of the `edge` unique. `edge` can
# be array of edges with the same source and target.
def make_logicalPart_unique(graph, edge, vertices, recursive = false)

  edges = edge.is_a?(Array) ? edge : [edge]

  edges_with_same_target = graph.edges.select { |e| e.target == edges[0].target }
  return if edges_with_same_target.size <= edges.size

  vertex_org = edges[0].target
  vertex_new = create_unique_symbol(vertex_org, Set.new(graph.vertices + vertices.keys))
  vertices[vertex_new] = vertices[vertex_org].dup
  make_target_unique(graph, edges, vertex_new)

  return unless recursive

  graph.adjacent(vertex_new, {:direction => :out, :type => :vertices}).uniq.each do |target|
    e =  graph.edges.select { |e| e.source == vertex_new and e.target == target }
    make_logicalPart_unique(graph, e, vertices, recursive)
  end

end

##__________________________________________________________________||
def create_unique_symbol(base, symbols)
  i = 1
  begin
    ret = "%s#%d" % [base.to_s, i]
    ret = ret.to_sym
    i += 1
  end while symbols.include?(ret)
  ret
end

##__________________________________________________________________||
