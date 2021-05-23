function I_top = topNodes(A)

% Create a directed graph from the adjacency matrix
G = digraph(A);

% Calculate sortest path distances of all node pairs
d = distances(G);

% Find nodes at the top of the food chains
I_top = find(all(isinf(d) | d==0, 1));
