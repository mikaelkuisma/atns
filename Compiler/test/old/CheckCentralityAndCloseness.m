function [G, inclosen, outclosen, betweencen] = CheckCentralityAndCloseness(matdata)
% a function that uses Matlab's "digraph" - command to find 
% closeness centrality and betweenness centrality metrics, returning
% corresponding values for each vertex/node. The "graph" G is also returned
% for plotting, etc. 
% mijuvest 20 of Aug, 2018

% see: https://se.mathworks.com/help/matlab/ref/graph.centrality.html for
% details


% contruction of the directed graph:
G = digraph(matdata~=0);

% incloseness and outcloseness for directed web:
inclosen = centrality(G, 'incloseness');
outclosen = centrality(G, 'outcloseness');

% betweenness:
betweencen = centrality(G, 'betweenness');


