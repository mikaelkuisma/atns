function [a, A] = allometricScaling(gType)
% gType: guild type ('Consumer' or 'Fish')

% Allometric scaling
if strcmpi(gType, 'fish')
    A = 0.11; % Killen et al. 2010, Killen et al. 2007
    a = 0.88; % Ectotherm vertebrates; Brose et al. 2006
elseif strcmpi(gType, 'consumer')
    A = 0.15; % Killen et al. 2010, Killen et al. 2007
    a = 0.314; % Invertebrates; Brose et al. 2006
else
    error('Unknown guild type')
end
