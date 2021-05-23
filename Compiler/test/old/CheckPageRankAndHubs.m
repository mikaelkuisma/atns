function [pR, hubs] = CheckPageRankAndHubs(G)
%checking pagerank and hubs (Matlab's built-in functions). 
%This requires the graph as an input. 
%mijuvest 7th of Feb, 2019

pR = centrality(G,'pagerank');
hubs = centrality(G,'hubs');
