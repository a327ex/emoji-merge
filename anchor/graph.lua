local graph = class:class_new()
function graph:graph_init()
  self.adjacency_list = {}
  self.graph_nodes = {}
  self.graph_edges = {}
  self.floyd_dists = {}
  return self
end

-- Nodes can be of any type but must be unique
-- g = graph()
-- g:graph_add_node(1)
-- g:graph_add_node('node_2')
function graph:graph_add_node(node)
  self.adjacency_list[node] = {}
  self:graph_set_nodes()
end

-- g = graph()
-- g:graph_add_node(1)
-- g:graph_remove_node(1)
function graph:graph_remove_node(node)
  for _node, list in pairs(self.adjacency_list) do
    self:graph_remove_edge(node, _node)
  end
  self.adjacency_list[node] = nil
  self:graph_set_nodes()
end

local function contains_edge(table, edge)
  for _, v in ipairs(table) do
    if (v[1] == edge[1] and v[2] == edge[2]) or (v[1] == edge[2] and v[2] == edge[1]) then
      return true
    end
  end
  return false
end

-- g = graph()
-- g:graph_add_node(1)
-- g:graph_add_node('node_2')
-- g:graph_add_edge(1, 'node_2')
function graph:graph_add_edge(node1, node2)
  table.insert(self.adjacency_list[node1], node2)
  table.insert(self.adjacency_list[node2], node1)
  self:graph_set_edges()
end

-- g = graph()
-- g:graph_add_node(1)
-- g:graph_add_node('node_2')
-- g:graph_add_edge(1, 'node_2')
-- g:graph_remove_edge(1, 'node_2')
function graph:graph_remove_edge(node1, node2)
  for i, node in ipairs(self.adjacency_list[node1]) do
    if node == node2 then
      table.remove(self.adjacency_list[node1], i)
      break
    end
  end
  for i, node in ipairs(self.adjacency_list[node2]) do
    if node == node1 then
      table.remove(self.adjacency_list[node2], i)
      break
    end
  end
  self:graph_set_edges()
end

-- Comments follow pseudocode from http://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm.
-- g = graph()
-- g:graph_add_node(1)
-- g:graph_add_node('node_2')
-- g:graph_add_edge(1, 'node_2')
-- g:graph_floyd_warshall()
-- print(g.floyd_dists[1]['node_2']) -> 1
function graph:graph_floyd_warshall()
  self:graph_set_nodes()
  self:graph_set_edges()

  -- initialize multidimensional to be array
  for _, node in ipairs(self.nodes) do
    self.floyd_dists[node] = {}
  end

  -- let floyd_dist be a |V|x|V| array of minimun distance initialized to infinity
  for _, node in ipairs(self.nodes) do
    for _, _node in ipairs(self.nodes) do
      self.floyd_dists[node][_node] = 10000 -- 10000 is big enough for an unweighted graph
      self.floyd_dists[_node][node] = 10000
    end
  end

  -- set dist[v][v] to 0
  for _, node in ipairs(self.nodes) do
    self.floyd_dists[node][node] = 0
  end

  -- set dist[u][v] to w(u, v) which is always 1 in the case of an unweighted graph
  for _, edge in ipairs(self.edges) do
    self.floyd_dists[edge[1]][edge[2]] = 1
    self.floyd_dists[edge[2]][edge[1]] = 1
  end

  -- main triple loop
  for _, nodek in ipairs(self.nodes) do
    for _, nodei in ipairs(self.nodes) do
      for _, nodej in ipairs(self.nodes) do
        if self.floyd_dists[nodei][nodek] + self.floyd_dists[nodek][nodej] < self.floyd_dists[nodei][nodej] then
          self.floyd_dists[nodei][nodej] = self.floyd_dists[nodei][nodek] + self.floyd_dists[nodek][nodej]
        end
      end
    end
  end
end

function graph:graph_get_edge(node1, node2)
  for _, node in ipairs(self.adjacency_list[node1]) do
    if node == node2 then
      return true
    end
  end
  return false
end

function graph:graph_set_nodes()
  self.nodes = {}
  for node, _ in pairs(self.adjacency_list) do
    table.insert(self.nodes, node)
  end
end

function graph:graph_set_edges()
  self.edges = {}
  for node, list in pairs(self.adjacency_list) do
    for _, _node in ipairs(list) do
      if not contains_edge(self.edges, {node, _node}) then
        table.insert(self.edges, {node, _node})
      end
    end
  end
end

function graph:graph_tostring()
  local str = "----\nAdjacency List: \n"
  for node, list in pairs(self.adjacency_list) do
    str = str .. node .. " ->   "
    for _, adj in ipairs(list) do
      str = str .. adj .. ", "
    end
    str = string.sub(str, 0, -3)
    str = str .. "\n"
  end
  str = str .. "\n"
  str = str .. "Nodes: \n"
  for _, node in ipairs(self.nodes) do
    str = str .. node .. "\n"
  end
  str = str .. "\n"
  str = str .. "Edges: \n"
  for _, edge in ipairs(self.edges) do
    str = str .. edge[1] .. ", " .. edge[2]
    str = str .. "\n"
  end
  str = str .. "\n"
  str = str .. "Floyd Warshall Distances: \n"
  for node, _ in pairs(self.floyd_dists) do
    for _node, _ in pairs(self.floyd_dists[node]) do
      str = str .. "(" .. node .. ", " .. _node .. ") = " .. self.floyd_dists[node][_node]
      str = str .. "\n"
    end
  end
  str = str .. "----\n"
  return str
end

return graph
