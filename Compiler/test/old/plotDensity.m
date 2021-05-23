function plotDensity(Results, Data, inds, jnd)

if nargin < 4
    jnd = 1:size(Results.allbiomasses, 2);
end

for i = 1:length(inds)
    ind = inds(i);
    figure
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0.51 0.33 0.49])
    plot(Results.allbiomasses(ind, jnd))
    title(sprintf('%s (%i)', ...
        Data.Guilds(ind).label, ind))
end
