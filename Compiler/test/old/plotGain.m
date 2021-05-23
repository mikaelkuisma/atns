function plotGain(Results, Data, inds, jnds, knd)

if (isempty(inds) || isequal(inds, 0)) && ~isempty(jnds)
    inds = [];
    jndsTmp = [];
    for j = 1:length(jnds)
        jnd = jnds(j);
        indsTmp = find(Data.adjacencyMatrix(:, jnd));
        jndsTmp = [jndsTmp ; jnd*ones(size(indsTmp))];
        inds = [inds ; indsTmp];
    end
    jnds = jndsTmp;
elseif (nargin < 3 || isempty(jnds) || isequal(jnds, 0)) && ~isempty(inds)
    jnds = [];
    indsTmp = [];
    for i = 1:length(inds)
        ind = inds(i);
        jndsTmp = find(Data.adjacencyMatrix(ind, :));
        indsTmp = [indsTmp ; ind*ones(size(jndsTmp))];
        jnds = [jnds ; jndsTmp];
    end
    inds = indsTmp;
elseif isscalar(inds) && ~isscalar(jnds)
    inds = inds*ones(size(jnds));
elseif isscalar(jnds) && ~isscalar(inds)
    jnds = jnds*ones(size(inds));
end

if nargin < 5
    knd = 1:size(Results.G_Daily, 2);
end

for i = 1:length(inds)
    ind = inds(i);
    jnd = jnds(i);
    figure
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0.51 0.33 0.49])
    plot(squeeze(Results.G_Daily(ind, jnd, knd)))
    title(sprintf('%s (%i) -> %s (%i)', ...
        Data.Guilds(jnd).label, jnd, ...
        Data.Guilds(ind).label, ind))
end
