function Results = updateResultsStruct(Results, Xend, Inds, OUT, X, i, Data, GI, Options)

if Options.Outputs.Biomass
    % Biomasses
    Results.B(:, i) = Xend(Data.Inds.iB);
end
if Options.Outputs.AllBiomasses
    % Biomasses for each day
    Results.allbiomasses(:, Data.ltspan*(i-1)+1:Data.ltspan*i) = X(:, 1:GI.nGuilds)';
end

if Options.Outputs.Catch
    % Catches
    Results.C(:, i) = Xend(Data.Inds.iC);
end

if Options.Outputs.Gain
    % Gain matrix
    Results.G(GI.iFeederGuilds, GI.iFoodGuilds, i) = ...
        reshape(Xend(Data.Inds.iG), GI.nFeederGuilds, GI.nFoodGuilds);
end

if isfield(Options.Outputs, 'GainDaily') && Options.Outputs.GainDaily
    % Primary production daily
    tInds = (Data.ltspan-1)*(i-1)+1:(Data.ltspan-1)*i;
    Results.G_Daily(GI.iFeederGuilds, GI.iFoodGuilds, tInds) = ...
        reshape(diff(X(:, Data.Inds.iG))', GI.nFeederGuilds, GI.nFoodGuilds, length(tInds));
end

if Options.Outputs.Loss
    % Loss matrix
    Results.L(GI.iFoodGuilds, GI.iFeederGuilds, i) = ...
        reshape(Xend(Data.Inds.iL), GI.nFoodGuilds, GI.nFeederGuilds);
end

if Options.Outputs.GainFish
    % Gain fish (reproduction)
    Results.GF(:, i) = Xend(Inds.iGF);
end

if Options.Outputs.SSB
    % Spawning stock biomass
    Results.SSB(:, i) = OUT.SSB;
end

if Options.Outputs.JB
    % Juvenile biomass
    Results.JB(:, i) = OUT.JB;
end

if Options.Outputs.Productivity
    % Primary production
    Results.P(:, i) = Xend(Inds.iP);
end

if Options.Outputs.ProductivityDaily
    % Primary production daily
    Results.P_Daily(:, (Data.ltspan-1)*(i-1)+1:(Data.ltspan-1)*i) = diff(X(:, Inds.iP))';
end
