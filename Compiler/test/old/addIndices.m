function Data = addIndices(Data,GuildInfo,Options)

Binds = [];
if Options.Outputs.Biomass
    Binds = 1:GuildInfo.nGuilds;
end
lastInd = length(Binds);

Cinds = [];
if Options.Outputs.Catch
    Cinds = lastInd + (1:GuildInfo.nFishGuilds);
end
lastInd = lastInd + length(Cinds);

GFinds = [];
if Options.Outputs.GainFish
    GFinds = lastInd + (1:GuildInfo.nFishGuilds);
end
lastInd = lastInd + length(GFinds);

Ginds = [];
if Options.Outputs.Gain
    Ginds = lastInd + (1:GuildInfo.nFeederGuilds*GuildInfo.nFoodGuilds);
end
lastInd = lastInd + length(Ginds);

Linds = [];
if Options.Outputs.Loss
    Linds = lastInd + (1:GuildInfo.nFoodGuilds*GuildInfo.nFeederGuilds);
end
lastInd = lastInd + length(Linds);

Pinds = [];
if Options.Outputs.Productivity
    Pinds = lastInd + (1:GuildInfo.nProducerGuilds);
end
% lastInd = lastInd + length(Linds);

Data.Inds.iB = Binds;
Data.Inds.iC = Cinds;
Data.Inds.iGF = GFinds;
Data.Inds.iG = Ginds;
Data.Inds.iL = Linds;
Data.Inds.iP = Pinds;