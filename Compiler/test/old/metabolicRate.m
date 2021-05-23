function [x, M] = metabolicRate(l, lw_a, lw_b, gType, MRef, aRef)
% x = a/aRef * (MRef/M)^A
%
% l: Body length [cm]
% lw_a, lw_b: length-weight model parameters
% gType: guild type ('Consumer' or 'Fish')
% MRef: body mass of the reference guild
% aRef: allometric constant of the reference guild 

WeightFresh = lengthToWeight(l, lw_a, lw_b);  % Body mass [g]
WeightDry = 0.2 * WeightFresh;
WeightCarbon = 0.53 * WeightDry;
M = 1e6 * WeightCarbon; % Body mass [ugC/m^3]

if nargin < 6
    aRef = 1; % assuming the reference guild is a producer for all of which a=1
end

if nargin < 5
    %MRef = 6.4e-5; % Lake Constance
    MRef = 3.05e-2; % Lake Vorts
end

if nargin < 4
    gType = 'Fish';
end

x = bodyMassToMetabolicRate(M, gType, MRef, aRef);