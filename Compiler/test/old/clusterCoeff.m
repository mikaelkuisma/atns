function cc = clusterCoeff(c_matrix, indeces); 
% a function that returns the clustering coefficient for directed networks 
% This can be used for both incoming and outgoing connections
% The output: number of "triangles" / maximum number of triangles available
% This should be used for each node separately
 
% a moving counter for the number of realized connections between two nodes
% (vertices) in the neighborhood of a node

cc = 0; 
if (isempty(indeces) || length(indeces) == 1)
    return; 
end

connections = 0; 
s = 2;

for ii = 1:(length(indeces)-1) 
    for jj = s:length(indeces)
        i = indeces(ii);
        j = indeces(jj);
        if (c_matrix(i,j) == 1 || c_matrix(j,i) == 1)
            %[i,j]
            connections = connections + 1;
        end
    end
    s = s+1;
    
end

% max. number of connections (different pairs of nodes):
max_connections = length(indeces)*(length(indeces)-1)/2;

cc = connections/max_connections; 