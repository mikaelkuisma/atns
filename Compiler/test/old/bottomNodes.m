function I_bottom = bottomNodes(A)

% Create a directed graph from the adjacency matrix
G = digraph(A);

% Calculate sortest path distances of all node pairs
d = distances(G);

% Find nodes at the bottom of the food chains
I_bottom = find(all(isinf(d) | d==0, 2))';
