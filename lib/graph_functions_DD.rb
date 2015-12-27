#!/usr/bin/env ruby
# Tai Sakuma <sakuma@fnal.gov>

require "graph_functions"


# Graph functions for Detector Description (DD)

##__________________________________________________________________||
# Makes the logicalPart at the target of the `edge` unique.
def make_logicalPart_unique(graph, edge, vertices)
  vertex_org = edge.target
  vertex_new = create_unique_symbol(vertex_org, Set.new(graph.vertices + vertices.keys))
  vertices[vertex_new] = vertices[vertex_org].dup
  make_target_unique(graph, edge, vertex_new)
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
