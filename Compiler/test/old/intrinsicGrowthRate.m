function r = intrinsicGrowthRate(M,MRef)
% r = a/aRef * (MRef/M)^A
%
% M: Body size
% MRef: Body size of the reference guild
%
% Boit et al. 2012 EcolLett Supporting information

aRef = 1; % assuming the reference guild is a producer for all of which a=1
a = 1;

if nargin < 2
    %MRef = 6.4e-5; % Lake Constance
    MRef = 3.05e-2; % Lake Vorts
end

A = 0.15;

r = a/aRef*(MRef/M)^A;

