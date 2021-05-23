function dXdt = atn_ode_biomass_gainfish(~,X,Data)
% ----------------------------------------------------------------------- %
% ----------------------------- PARAMETERS ------------------------------ %
% ----------------------------------------------------------------------- %



% ----------------------------------------------------------------------- %
% FEEDING LINKS
% ----------------------------------------------------------------------- %

% Feeding links between feeders and food
% adjacencyMatrix = Data.adjacencyMatrix;
% Functional response exponent parameters for each feeding link
% q = Data.q;
qVec = Data.qVec;
% Feeding interference coefficients for each feeding link
% d = Data.d;
dVec = Data.dVec;
% Relative food preferences of feeders for each feeding link
% omega = Data.omega;
omegaVec = Data.omegaVec;
% Assimilation efficiencies for each feeding link
% e = Data.e;
eVec = Data.eVec;
% Maximum consumption rates for each feeding link
y = Data.y;
yVec = Data.yVec;
% Half saturation constants to the power of q for each feeding link
% B0_pow_q = Data.B0_pow_q;
B0_pow_qVec = Data.B0_pow_qVec;

% ----------------------------------------------------------------------- %
% PRODUCERS
% ----------------------------------------------------------------------- %

% Carrying capacity of autotrophs for current year
K = Data.K.values(Data.year);
% Intrinsic growth rate of producers
r = Data.r;
% Competition coefficients of producers
% c = Data.c;
C = Data.C;
% Fractions of exudation for producers
s = Data.s;

% ----------------------------------------------------------------------- %
% CONSUMERS AND FISHES
% ----------------------------------------------------------------------- %
% Metabolic rate of consumers and fishes
x = Data.x;
xVec = Data.xVec;
% Fractions of assimilated C used for biomass gains for feeders
% ax = Data.ax;
faDiagMTX = Data.faDiagMTX;
faVec = Data.faVec;
% axFullDiagMTX = Data.axFullDiagMTX;
% Fractions of assimilated C respired by maintenance for feeders
% fm = Data.fm;
fmx = Data.fmx;
% Fraction of fish biomass lost to fishery
E = Data.E;
% Fraction of surpluss energy used for reproduction for fish
invest = Data.invest;
% Proportion of 'mature individuals' for fish
P_mat = Data.P_mat;

% ----------------------------------------------------------------------- %
% DETRITUS
% ----------------------------------------------------------------------- %

% Dissolution rate of undissolved detritus
diss_rate = Data.diss_rate;

% ----------------------------------------------------------------------- %
% MISC
% ----------------------------------------------------------------------- %

% Precalculated index vectors etc.
GuildInfo = Data.GuildInfo;
% New variables for speed up by avoiding repetitive computations or indexing
B = X(1:GuildInfo.nGuilds);
% Producer biomasses
bProducerGuilds = B(GuildInfo.iProducerGuilds);
% Consumer and fish biomasses
bConsumerAndFishGuilds = B(GuildInfo.iConsumerAndFishGuilds);
% Feeder biomasses
bFeederGuilds = B(GuildInfo.iFeederGuilds);
bFeeder = bFeederGuilds(Data.I);
% Food biomasses
bFoodGuilds = B(GuildInfo.iFoodGuilds);
bFood = bFoodGuilds(Data.J);
% Undissolved detritus biomass
bDOC1 = B(GuildInfo.iDOC1);

% ----------------------------------------------------------------------- %



% ----------------------------------------------------------------------- %
% -------------------------------- MODEL -------------------------------- %
% ----------------------------------------------------------------------- %

% Preallocate derivative vector
dXdt = zeros(length(X),1);

% % Preallocate biomass derivative vector
% dBdt = zeros(GuildInfo.nGuilds,1);

% ----------------------------------------------------------------------- %
% FUNCTIONAL RESPONSE MATRIX
% ----------------------------------------------------------------------- %

% Bmx_pow_q = repmat(bFoodGuilds',GuildInfo.nFeederGuilds,1).^q;
% Ftop = omega.*repmat(bFoodGuilds',GuildInfo.nFeederGuilds,1).^q;

% omega_times_Bmx_pow_q = omega.*Bmx_pow_q;
omegaBmxpowq = zeros(GuildInfo.nFeederGuilds,GuildInfo.nFoodGuilds);
% omega_times_Bmx_pow_q(Data.IJ) = omega(Data.IJ).*bFoodGuilds(Data.J).^q(Data.IJ);
omegaBpowqVec = omegaVec.*bFood.^qVec;
omegaBmxpowq(Data.IJ) = omegaBpowqVec;

% Ftop = omega_times_Bmx_pow_q;
Ftop = omegaBpowqVec;

% Fbot1 = B0_pow_q;
% Fbot1 = B0_pow_q(Data.IJ);
Fbot1 = B0_pow_qVec;

% Fbot2 = diag(sum(omega.*Bmx_pow_q,2))*adjacencyMatrix;
% Fbot2 = diag(sum(omega_times_Bmx_pow_q,2))*adjacencyMatrix;
sumomegaBmxpowq = sum(omegaBmxpowq,2);
% Fbot2 = nonzeros(diag(sum(omegaBmxpowq,2))*adjacencyMatrix);
% Fbot2 = nonzeros(diag(sumomegaBmxpowq)*adjacencyMatrix);
Fbot2 = sumomegaBmxpowq(Data.I);

% Fbot3 = diag(bFeederGuilds)*d.*B0_pow_q;
% Fbot3 = bFeederGuilds(Data.I).*d(Data.IJ).*B0_pow_q(Data.IJ);
Fbot3 = bFeeder.*dVec.*B0_pow_qVec;

Fbot = Fbot1 + Fbot2 + Fbot3;

F = zeros(GuildInfo.nFeederGuilds,GuildInfo.nFoodGuilds);
% F(Data.IJ) = Ftop(Data.IJ)./Fbot(Data.IJ);
F(Data.IJ) = Ftop./Fbot;
% F = Ftop./Fbot;
% F(isnan(F)) = 0;

Fvec = Ftop./Fbot;

% ----------------------------------------------------------------------- %
% GAINS AND LOSSES
% ----------------------------------------------------------------------- %

yxBF = y.*repmat(x.*bFeederGuilds,1,GuildInfo.nFoodGuilds).*F;
yxBFVec = yVec.*xVec.*bFeeder.*Fvec;

% Gain from resources
% gainMTX = spdiags(ax,0,length(ax),length(ax))*ytimesxtimesBtimesF;
% gainMTX = diag(ax)*ytimesxtimesBtimesF;
gainMTX = faDiagMTX*yxBF;
gainVec = faVec.*yxBFVec;

if Data.Options.isNewVersion
    % respiredMTX = (speye(GuildInfo.nFeederGuilds)-faDiagMTX)*yxBF;
    respiredVec = yxBFVec-gainVec;
    % respired = sum(sum(respiredMTX));
    respired = sum(respiredVec);
end

% gainMTX = axFullDiagMTX*ytimesxtimesBtimesF;
gainVEC = sum(gainMTX,2);
gainVEC = full(gainVEC);

% Loss to consumers
% lossMTX = (ytimesxtimesBtimesF./e)';
% lossMTX(isnan(lossMTX)) = 0;

lossMTX = zeros(GuildInfo.nFeederGuilds,GuildInfo.nFoodGuilds);
% lossMTX(Data.IJ) = yxBF(Data.IJ)./e(Data.IJ);
lossVec = yxBFVec./eVec;
lossMTX(Data.IJ) = lossVec;
% lossMTX = lossMTX';

% lossVEC = sum(lossMTX,2);
lossVEC = sum(lossMTX)';
% lossVEC = full(lossVEC);

% Loss to maintenance
% lConsumerAndFishMaintenance = fm.*x.*bConsumerAndFishGuilds;
lConsumerAndFishMaintenance = fmx.*bConsumerAndFishGuilds;
% lFeederMaintenance = bx.*x.*bFeederGuilds;

% Loss of adult fishes to fishing
lAdultFishFishing = E.*B(GuildInfo.iAdultFishGuilds);

% ----------------------------------------------------------------------- %
% PRODUCER BIOMASS DERIVATIVES
% ----------------------------------------------------------------------- %

% PRODUCER gain from logistic growth
% G = 1 - (c'*bProducerGuilds + bProducerGuilds)/K; %
% G = 1 - c'*bProducerGuilds/K; % Boit et al.
% G = 1 - (c'*bProducerGuilds + bProducerGuilds)/K; %
C = 1/6*ones(6,6)-1/6*eye(6,6)+6*eye(6,6);
G = 1 - C*bProducerGuilds/K;

ProducerGrossGrowth = r.*bProducerGuilds.*G;
gProducerNetGrowth = ProducerGrossGrowth.*(1-s);

% PRODUCER loss to consumption
lProducerConsumption = lossVEC(GuildInfo.iProducerGuildsInFood);

% dBdt(GuildInfo.iProducerGuilds) = + gProducerNetGrowth ...
%                                   - lProducerConsumption;
dXdt(GuildInfo.iProducerGuilds) = + gProducerNetGrowth ...
                                  - lProducerConsumption;

% ----------------------------------------------------------------------- %
% FISH BIOMASS DERIVATIVES
% ----------------------------------------------------------------------- %
                              
% FISH maintenance loss
lFishMaintenance = lConsumerAndFishMaintenance(GuildInfo.iFishGuildsInConsumers);
% lFishMaintenance = lFeederMaintenance(GuildInfo.iFishGuildsInFeeders);

% FISH gain from consumption
gFishConsumption = gainVEC(GuildInfo.iFishGuildsInFeeders);

% FISH loss to consumption
lFishConsumption = zeros(GuildInfo.nFishGuilds,1);
lFishConsumption(GuildInfo.iFishFoodInFishGuilds) = lossVEC(GuildInfo.iFishGuildsInFood);

% FISH loss to fishing
lFishFishing = zeros(GuildInfo.nFishGuilds,1);
lFishFishing(GuildInfo.iAdultFishGuildsInFish) = lAdultFishFishing;

% FISH gained biomass available for growth and reproduction
% gFishBiomassAvailable = max(gFishConsumption - lFishMaintenance,0);
gFishBiomassAvailable = max(gFishConsumption ...
    - lFishMaintenance ...
    - lFishConsumption ...
    - lFishFishing,0);

% FISH loss to reproduction
% lFishReproduction = invest.*gFishBiomassAvailable.*P_mat(GuildInfo.FishAges+1);
lFishReproduction = invest.*gFishBiomassAvailable.*P_mat;





% dBdt(GuildInfo.iFishGuilds) = - lFishMaintenance ...
%                               + gFishConsumption ...
%                               - lFishConsumption ...
%                               - lFishFishing ...
%                               - lFishReproduction;
dXdt(GuildInfo.iFishGuilds) = - lFishMaintenance ...
                              + gFishConsumption ...
                              - lFishConsumption ...
                              - lFishFishing ...
                              - lFishReproduction;
          
% ----------------------------------------------------------------------- %
% CONSUMER BIOMASS DERIVATIVES
% ----------------------------------------------------------------------- %

% CONSUMER maintenance loss
lConsumerMaintenance = lConsumerAndFishMaintenance(GuildInfo.iNonFishGuildsInConsumers);

% CONSUMER gain from consumption
gConsumerConsumption = gainVEC(GuildInfo.iNonFishGuildsInFeeders);

% CONSUMER loss to consumption
lConsumerConsumption = lossVEC(GuildInfo.iConsumerGuildsInFood);

% dBdt(GuildInfo.iConsumerGuilds) = - lConsumerMaintenance ...
%                                   + gConsumerConsumption ...
%                                   - lConsumerConsumption;
dXdt(GuildInfo.iConsumerGuilds) = - lConsumerMaintenance ...
                                  + gConsumerConsumption ...
                                  - lConsumerConsumption;

% ----------------------------------------------------------------------- %
% DETRITUS BIOMASS DERIVATIVES
% ----------------------------------------------------------------------- %

% UNDISSOLVED DETRITUS gain from consumption
% gDOC1Consumption = sum(sum(lossMTX.*(1-e)'));
gDOC1Consumption = sum(lossVec.*(1-eVec));

% UNDISSOLVED DETRITUS gain from exudations ( = Gross - Net )
gDOC1Exudation = sum(ProducerGrossGrowth.*s);

% UNDISSOLVED DETRITUS loss from dissolution
% diss_rate = 0.1;
lDOC1Dissolution = diss_rate*bDOC1;

% dDOC1dt = + gDOC1Consumption ...
%           + gDOC1Exudation ...
%           - lDOC1Dissolution;

if Data.Options.isNewVersion
    gDOC1ConsumerAndFishMaintenance = sum(lConsumerAndFishMaintenance);
    % dDOC1dt = + gDOC1Consumption ...
    %           + gDOC1Exudation ...
    %           + gDOC1ConsumerAndFishMaintenance ...
    %           + respired ...
    %           - lDOC1Dissolution;
    dXdt(GuildInfo.iDOC1) = + gDOC1Consumption ...
        + gDOC1Exudation ...
        + gDOC1ConsumerAndFishMaintenance ...
        + respired ...
        - lDOC1Dissolution;
else
    dXdt(GuildInfo.iDOC1) = + gDOC1Consumption ...
                            + gDOC1Exudation ...
                            - lDOC1Dissolution;
end

% DISSOLVED DETRITUS gain from dissolution
gDOC2Dissolution = lDOC1Dissolution;

% DISSOLVED DETRITUS loss to consumption 

% (bacteria)
lDOC2Consumption = sum(yxBF(:,GuildInfo.iDOC2InFoodGuilds));

% (producers)
if Data.Options.isNewVersion
    lDOC2ProducerGrowth = sum(ProducerGrossGrowth);
else
    lDOC2ProducerGrowth = 0; 
end

% dDOC2dt = + gDOC2Dissolution ...
%           - lDOC2Consumption ...
%           - lDOC2ProducerGrowth;
dXdt(GuildInfo.iDOC2) = + gDOC2Dissolution ...
                        - lDOC2Consumption ...
                        - lDOC2ProducerGrowth;

% dBdt([GuildInfo.iDOC1 GuildInfo.iDOC2]) = [dDOC1dt ; dDOC2dt];

% ----------------------------------------------------------------------- %
% CONCATENATE DERIVATIVES OF BIOMASSES, CATCHES, GAIN FISH, GAIN AND LOSS
% ----------------------------------------------------------------------- %

% Derivative of fishing
% dCdt = lAdultFishFishing;
% dXdt(Data.iC) = lAdultFishFishing;

% Derivative of fish reproduction
% dGFdt = gFishBiomassAvailable./B(GuildInfo.iFishGuilds);
% dGFdt = lFishReproduction;
dXdt(Data.iGF) = lFishReproduction;

% Derivative of gains
% dGdt = gainMTX(:);
% dXdt(Data.iG) = gainMTX(:);
% dXdt(Data.iG) = gainVec;

% Derivative of losses
% dLdt = lossMTX(:);
% dXdt(Data.iL) = lossMTX(:);
% dXdt(Data.iL) = lossVec;

% dXdt = [dBdt ; dCdt ; dGFdt ; dGdt ; dLdt];

% if any(~isreal(dXdt))
% %     dXdt
% end

% debugBac = false;
% if debugBac
%     
%     iBinC = GuildInfo.iBacInConsumers;
%     iB = GuildInfo.iBac;
%     
%     fprintf('time                 : %f\n',t);
%     fprintf('Loss to maintenance  : %f\n',lConsumerMaintenance(iBinC));
%     fprintf('Loss to consumption  : %f\n',lConsumerConsumption(iBinC));
%     fprintf('Gain from consumption: %f\n',gConsumerConsumption(iBinC));
%     fprintf('Biomass derivative   : %f\n\n',dBdt(iB));
%     
%     [];
% end
