function x = bodyMassToMetabolicRate(M, gType, MRef, aRef)

% Allometric scaling
[a, A] = allometricScaling(gType);

if nargin < 4
    aRef = 1; % assuming the reference guild is a producer for all of which a=1
end

if nargin < 3
    %MRef = 6.4e-5; % Lake Constance
    MRef = 3.05e-2; % Lake Vorts
end

x = a/aRef .* (MRef./M).^A;