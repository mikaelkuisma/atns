cd C:\MyTemp\GitHubRepositories\ATN\ArticleCodes\NoiseLC\Data
l = ls;
l = l(3:end,:);

for i = 1:size(l,1)
    filename = strtrim(l(i,:));
    if contains(filename, '.mat')
        load(filename)
        if isfield(Data, 'communityMatrix')
            Data.adjacencyMatrix = Data.communityMatrix;
            Data = rmfield(Data, 'communityMatrix');
            whos
            save(filename, 'Data')
        end
    end
end