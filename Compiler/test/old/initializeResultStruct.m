function Results = initializeResultStruct(GuildInfo,n,m,Outputs)

if nargin < 3
    m = 0;
end
if nargin < 2
    n = 0;
end

if Outputs.Biomass
    Results.B = zeros(GuildInfo.nGuilds,n);
end
if Outputs.AllBiomasses
    Results.allbiomasses = zeros(GuildInfo.nGuilds,n*m);
end
if Outputs.Catch
    Results.C = zeros(GuildInfo.nFishGuilds,n);
end
if Outputs.GainFish
    Results.GF = zeros(GuildInfo.nFishGuilds,n);
end
if Outputs.Gain
    Results.G = zeros(GuildInfo.nGuilds,GuildInfo.nGuilds,n);
end
if isfield(Outputs, 'GainDaily') && Outputs.GainDaily
    Results.G_Daily = zeros(GuildInfo.nGuilds,GuildInfo.nGuilds,n*(m-1));
end
if Outputs.Loss
    Results.L = zeros(GuildInfo.nGuilds,GuildInfo.nGuilds,n);
end
if Outputs.SSB
    Results.SSB = zeros(GuildInfo.nFishSpecies,n);
end
if Outputs.JB
    Results.JB = zeros(GuildInfo.nFishSpecies,n);
end
if Outputs.Productivity
    Results.P = zeros(GuildInfo.nProducerGuilds,n);
end
if Outputs.ProductivityDaily
    Results.P_Daily = zeros(GuildInfo.nProducerGuilds,n*(m-1));
end