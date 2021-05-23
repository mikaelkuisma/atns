function StatsForAllGraphs
% a function that draws histograms for all graph theory parameters
% calculated for 100 random food webs with 36 species. This also calculates
% correlation coefficients pairwise for all variables to see if there are
% linear correlations.
% Feb 6 2019 by mijuvest
clc,close all;
% loading web structure and other network properties
load('filteredwebs.mat', 'filtered_outputStructure');

nowebs = 100;
nospecies = 36;

% network metrics, empty data vectors:
inConnections = zeros(nowebs*nospecies, 1);
outConnections =  zeros(nowebs*nospecies, 1);
cc_incoming =  zeros(nowebs*nospecies, 1);
cc_outgoing = zeros(nowebs*nospecies, 1);
trophLevel = zeros(nowebs*nospecies,3);
incloseness = zeros(nowebs*nospecies,1);
outcloseness = zeros(nowebs*nospecies,1);
betweenness = zeros(nowebs*nospecies,1);
pagerank = zeros(nowebs*nospecies,1);
all_hubs = zeros(nowebs*nospecies,1);

%labelList = {};

% going thru 100 webs
for ww = 1:nowebs
    
    Data = filtered_outputStructure(ww).data;
    %[sizeX, sizeY] = size(Data.masses);
   
    % Using Matlab's built-in functions here
    [G, inclosen, outclosen, betweencen] = CheckCentralityAndCloseness(Data.adjacencyMatrix);
    [pr, hubs] = CheckPageRankAndHubs(G);
    
    for qq = 1:nospecies
        inConnections((ww-1)*nospecies + qq) = Data.degree(qq).in;
        outConnections((ww-1)*nospecies + qq) = Data.degree(qq).out;
        cc_incoming((ww-1)*nospecies + qq) = Data.degree(qq).ccin;
        cc_outgoing((ww-1)*nospecies + qq) = Data.degree(qq).ccout;
        trophLevel((ww-1)*nospecies + qq,1) = Data.TrophLevel(qq).average;
        trophLevel((ww-1)*nospecies + qq,2) = Data.TrophLevel(qq).preyaveraged;
        trophLevel((ww-1)*nospecies + qq,3) = Data.TrophLevel(qq).shortestpath;
        incloseness((ww-1)*nospecies + qq) = inclosen(qq);
        outcloseness((ww-1)*nospecies + qq) = outclosen(qq);
        betweenness((ww-1)*nospecies + qq) = betweencen(qq);
        pagerank((ww-1)*nospecies + qq) = pr(qq);
        all_hubs((ww-1)*nospecies + qq) = hubs(qq);
        %labelList{qq} = Data.Guilds(qq).label;
    end
     
end


figure(1);

subplot(3,2,1);
h1 = histogram(inConnections,20, 'Normalization','probability');
h1.BinWidth = 1;
ylabel('probability');
xlabel('indegree');

subplot(3,2,2);
h2= histogram(outConnections,20, 'Normalization','probability');
h2.BinWidth = 1;
ylabel('probability');
xlabel('outdegree');

subplot(3,2,3);
histogram(cc_incoming, 'Normalization','probability');
ylabel('probability');
xlabel('clustering coefficient, incoming');

subplot(3,2,4);
histogram(cc_outgoing, 'Normalization','probability');
ylabel('probability');
xlabel('clustering coefficient, outgoing');

subplot(3,2,5);
histogram(incloseness,'Normalization','probability');
ylabel('probability');
xlabel('incloseness');

subplot(3,2,6);
histogram(outcloseness,'Normalization','probability');
ylabel('probability');
xlabel('outcloseness');


figure(2);

subplot(4,1,1);
h1 = histogram(inConnections,20, 'Normalization','probability');
hold on;
h2= histogram(outConnections,20, 'Normalization','probability');
h1.BinWidth = 1;
h2.BinWidth = 1;
xlabel('connections');
ylabel('probability');
legend('indegree', 'outdegree');

subplot(4,1,2);
h3 = histogram(cc_incoming, 'Normalization','probability');
hold on;
h4 = histogram(cc_outgoing, 'Normalization','probability');
h3.BinWidth = 0.05;
h4.BinWidth = 0.05;

ylabel('probability');
xlabel('clustering coefficient');
legend('incoming', 'outgoing');

subplot(4,1,3);
h5 = histogram(incloseness, 'Normalization','probability');
hold on;
h6 = histogram(outcloseness, 'Normalization','probability');
h5.BinWidth = 0.001;
h6.BinWidth = 0.001;

ylabel('probability');
xlabel('closeness');
legend('incoming', 'outgoing');

subplot(4,1,4);
h7 = histogram(betweenness, 0:25, 'Normalization','probability')
max(h7.Data)
h7.BinWidth = 1;

ylabel('probability');
xlabel('betweenness');

figure(3)
subplot(3,1,1);
h8 = histogram(pagerank, 'Normalization','probability');
ylabel('probability');
xlabel('page rank');

subplot(3,1,2);
h9 = histogram(all_hubs, 'Normalization','probability');
h9.BinWidth = 0.001;
ylabel('probability');
xlabel('hubs');

subplot(3,1,3);
h10 = histogram(trophLevel(:,1),'Normalization','probability');
h10.BinWidth = 0.1;
ylabel('probability');
xlabel('average trophical level');



%correlation coefficients for all data:


allVars = [inConnections outConnections cc_incoming cc_outgoing incloseness outcloseness betweenness pagerank all_hubs trophLevel(:,1) ];
correlations = corrcoef(allVars);

colNames = {'indegree', 'outdegree', 'cc_in', 'cc_out', 'incloseness', 'outcloseness', 'betweenness', 'pagerank', 'hubs', 'troph_level'};
rowNames = colNames;

% CORR.indegree_vs_outdegree = correlations(1,2);
% CORR.indegree_vs_cc_incoming = correlations(1,3);
% CORR.indegree_vs_cc_outgoing = correlations(1,4);
% CORR.indegree_vs_incloseness = correlations(1,5);
% CORR.indegree_vs_outcloseness = correlations(1,6);
% CORR.indegree_vs_betweenness = correlations(1,7);
% CORR.outdegree_vs_cc_incoming = correlations(2,3);
% CORR.outdegree_vs_cc_outgoing = correlations(2,4);
% CORR.outdegree_vs_incloseness = correlations(2,5);
% CORR.outdegree_vs_outcloseness = correlations(2,6);
% CORR.outdegree_vs_betweenness = correlations(2,7);
% 
% 
CORR = array2table(correlations,'RowNames',rowNames,'VariableNames', colNames)
%CORR = triu(CORR)






