function FParams(Data, inds, jnds)

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


fprintf('\n')
for i = 1:length(inds)
    ind = inds(i);
    jnd = jnds(i);
    B0 = full(Data.B0(ind, jnd));
    d = full(Data.d(ind, jnd));
    fprintf('%4s (%i) -> %4s (%i) \t B0: %i, d: %.0e \n', ...
        Data.Guilds(ind).label, ind, ...
        Data.Guilds(jnd).label, jnd, ...
        B0, d)
end
fprintf('\n')