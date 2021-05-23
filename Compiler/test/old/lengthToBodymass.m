function M = lengthToBodymass(l, lw_a, lw_b, f_dry, f_carbon)

if nargin < 5
    f_carbon = 0.53;
end
if nargin < 4
    f_dry = 0.2;
end

WeightFresh = lengthToWeight(l, lw_a, lw_b);  % Body mass [g]
WeightDry = f_dry * WeightFresh;
WeightCarbon = f_carbon * WeightDry;
M = 1e6 * WeightCarbon; % Body mass [ugC/m^3]
