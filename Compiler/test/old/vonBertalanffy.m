function l = vonBertalanffy(l0,linf,k,a)
% TODO: make it work for different input sizes
l = linf - (linf - l0).*exp(-diag(a)*k);