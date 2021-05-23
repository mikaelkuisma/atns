function Xinit = initialValueVector(Binit, GI, OdeOutputs)

Cinit = [];
GFinit = [];
Ginit = [];
Linit = [];
Pinit = [];

if ~OdeOutputs.Biomass
    Binit = [];
end
if OdeOutputs.Catch
    Cinit = zeros(GI.nFishGuilds,1);
end
if OdeOutputs.GainFish
    GFinit = zeros(GI.nFishGuilds,1);
end
if OdeOutputs.Gain
    Ginit = zeros(GI.nFeederGuilds*GI.nFoodGuilds,1);
end
if OdeOutputs.Loss
    Linit = zeros(GI.nFoodGuilds*GI.nFeederGuilds,1);
end
if OdeOutputs.Productivity
    Pinit = zeros(GI.nProducerGuilds,1);
end

Xinit = [Binit ; Cinit ; GFinit ; Ginit ; Linit ; Pinit];