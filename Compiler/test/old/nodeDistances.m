function L = nodeDistances(A)

% Create a directed graph from the adjacency matrix
G = digraph(A);

% Calculate sortest path distances of all node pairs
d = distances(G);

% Find nodes at the bottom of the food chains
I_bottom = bottomNodes(A);

% Find nodes at the top of the food chains
I_top = topNodes(A);

D = d(I_top, I_bottom); %#ok<FNDSB>

DD = D(~isinf(D) & D~=0);

L.mean = mean(DD);
L.median = median(DD);
L.min = min(DD);
L.max = max(DD);

fprintf('number of food chains: %i\n', length(DD))
fprintf('Mean food chain length: %f\n', L.mean)
fprintf('Median food chain length: %f\n', L.median)
fprintf('Minimum food chain length: %f\n', L.min)
fprintf('Maximum food chain length: %f\n', L.max)