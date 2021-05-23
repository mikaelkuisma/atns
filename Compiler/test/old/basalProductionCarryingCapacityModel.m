function Kmodel = basalProductionCarryingCapacityModel(type,Kmean,Kstd,Kacc)

if nargin < 4 || isnan(Kacc)
    Kacc = [];
end
if nargin < 3 || isnan(Kstd)
    Kstd = [];
end

Kmodel.type = type;
Kmodel.mean = Kmean;
Kmodel.standard_deviation = Kstd;
Kmodel.autocorrelation = Kacc;
