function M = metabolicRateToBodyMass(x, gType, MRef)
% M = (MRef/(x .* aRef/a).^(1/A))

% Allometric scaling
[a, A] = allometricScaling(gType);

% TODO: get aRef as input argument (store ref selection in Guilds.isRefGuild)
aRef = 1; % assuming the reference guild is a producer for all of which a=1
% TODO: get MRef as input argument (store ref selection in Guilds.isRefGuild)
%MRef = 6.4e-5; % Lake Constance
MRef = 3.05e-2; % Lake Vorts

M = (MRef/(x .* aRef/a).^(1/A));