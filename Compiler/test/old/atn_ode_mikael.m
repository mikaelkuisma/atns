function dXdt = atn_ode(t,X,Data,Options)
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
muK = Data.K.values(Data.year);
if Options.Model.GrowthSeason.K.Version == 1
    K = muK;
elseif Options.Model.GrowthSeason.K.Version == 2
    AK = Options.Model.GrowthSeason.K.Params;
    sc_K = 1/((4*AK)/pi + (1 - AK));
    K = sc_K*(muK + AK*muK*(2*sin(pi/Data.nGrowthDays*t)-1));
elseif Options.Model.GrowthSeason.K.Version == 3 % Antti's update :)
    k = 1/(1+exp(Options.Model.GrowthSeason.Params.z*(t-Options.Model.GrowthSeason.Params.tmax)));
    K = k*muK;
elseif Options.Model.GrowthSeason.K.Version == 4 % New, more comparable K model
    kk = 1/(1+exp(Options.Model.GrowthSeason.Params.z*(t-Options.Model.GrowthSeason.Params.tmax)));
    k = Options.Model.GrowthSeason.Params.kavg+Options.Model.GrowthSeason.Params.d*(2*kk-1);
    K = k*muK;
elseif Options.Model.GrowthSeason.K.Version == 5 % Mirror of K4, i.e. seasonally increasing K
    kk = 1/(1+exp(Options.Model.GrowthSeason.Params.z*(t-Options.Model.GrowthSeason.Params.tmax)));
    ka = Options.Model.GrowthSeason.Params.kavg+Options.Model.GrowthSeason.Params.d*(2*kk-1);
    k = (((Data.nGrowthDays-ka)-(Data.nGrowthDays)))+2;
    K = k*muK;
elseif Options.Model.GrowthSeason.K.Version == 6 % Mirror of K2 = U-shaped seasonal K (cf. Uszko et al. 2017)
    AK = Options.Model.GrowthSeason.K.Params;
    sc_K = 1/((4*AK)/pi + (1 - AK));
    K = sc_K*(muK + AK.*muK.*(((Data.nGrowthDays-(2*sin(pi/Data.nGrowthDays.*t)-1))-Data.nGrowthDays)));
end

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
% f_a = Data.f_a;
f_aDiagMTX = Data.f_aDiagMTX;
f_aVec = Data.f_aVec;
% f_aFullDiagMTX = Data.f_aFullDiagMTX;
% Fractions of assimilated C respired by maintenance for feeders
% f_m = Data.f_m;
f_mx = Data.f_mx;
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
bPOC = B(GuildInfo.iPOC);

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

Fvec = Ftop./Fbot;
%log10(Fvec)
%asdsa
%Fvec(:)=1.0;
F = zeros(GuildInfo.nFeederGuilds,GuildInfo.nFoodGuilds);
% F(Data.IJ) = Ftop(Data.IJ)./Fbot(Data.IJ);
F(Data.IJ) = Fvec;
% F = Ftop./Fbot;
% F(isnan(F)) = 0;


% ----------------------------------------------------------------------- %
% GAINS AND LOSSES
% ----------------------------------------------------------------------- %

yxBF = y.*repmat(x(GuildInfo.iFeederGuildsInConsumersAndFish).*bFeederGuilds,1,GuildInfo.nFoodGuilds).*F;
yxBFVec = yVec.*xVec.*bFeeder.*Fvec;

% Gain from resources
% gainMTX = spdiags(f_a,0,length(f_a),length(f_a))*ytimesxtimesBtimesF;
% gainMTX = diag(f_a)*ytimesxtimesBtimesF;
gainMTX = f_aDiagMTX*yxBF;
gainVec = f_aVec.*yxBFVec;

if Options.isNewVersion
    % respiredMTX = (speye(GuildInfo.nFeederGuilds)-f_aDiagMTX)*yxBF;
    respiredVec = yxBFVec-gainVec;
    % respired = sum(sum(respiredMTX));
    respired = sum(respiredVec);
end

% gainMTX = f_aFullDiagMTX*ytimesxtimesBtimesF;
gainVEC = sum(gainMTX,2);
gainVEC = full(gainVEC);

% Loss to consumers
% lossMTX = (ytimesxtimesBtimesF./e)';
% lossMTX(isnan(lossMTX)) = 0;

lossMTX = zeros(GuildInfo.nFeederGuilds,GuildInfo.nFoodGuilds);
% lossMTX(Data.IJ) = yxBF(Data.IJ)./e(Data.IJ);
lossVec = yxBFVec./eVec;
lossMTX(Data.IJ) = lossVec;
lossMTX = lossMTX';

lossVEC = sum(lossMTX,2);
% lossVEC = sum(lossMTX)';
% lossVEC = full(lossVEC);

% Loss to maintenance
% lConsumerAndFishMaintenance = f_m.*x.*bConsumerAndFishGuilds;
lConsumerAndFishMaintenance = f_mx.*bConsumerAndFishGuilds;
% lFeederMaintenance = f_m.*x.*bFeederGuilds;

% Loss of fishes to fishing
lFishFishing = E.*B(GuildInfo.iFishGuilds);

% ----------------------------------------------------------------------- %
% PRODUCER BIOMASS DERIVATIVES
% ----------------------------------------------------------------------- %

%%% Producers growth model versions
%r = Data.r; %%% Intrinsic growth rate of procuders

ri = Data.r; %%% Intrinsic growth rate of procuders

if ~isfield(Options.Model.GrowthSeason, 'AutotrophR') || Options.Model.GrowthSeason.AutotrophR.Version == 1
    r = ri;
elseif Options.Model.GrowthSeason.AutotrophR.Version == 2
    I0 = Options.Model.GrowthSeason.AutotrophR.Params.I0; % Half sat.irradiance (W/m2)
    I = Options.Model.GrowthSeason.AutotrophR.Params.I(t);
     % simulated irradiance data
    h = Options.Model.GrowthSeason.AutotrophR.Params.h; % epilimnion depth(m)
    chi1 = Options.Model.GrowthSeason.AutotrophR.Params.chi1; % light extinction coefficient (1/m)
    chi2 = Options.Model.GrowthSeason.AutotrophR.Params.chi2; % self-shading coefficient (m2/gC)
    CPhyt = sum(bProducerGuilds);
    chi = chi1*chi2*CPhyt; % Is this CPhyt = "phytoplankton concentration"
    %cl = (1/(chi*h)).*log10((I0+I)/(I0+(I.*(exp(-1*(chi*h)))))); % light coefficient
    chih = chi*h;
    cl = (1/chih).*log((I0+I)./(I0+(I.*(exp(-1*chih))))); % light coefficient
    cl = cl*Options.Model.GrowthSeason.AutotrophR.Params.sc;
    % Note! Boit et al. used "log10" --> odd results...
    r = cl.*ri;
    
%     figure(1000)
%     hax = get(gcf, 'Children');
%     if ~isempty(hax)
%         hax = subplot(3,1,1);
%         title('Irradiance')
%         hl = get(hax, 'Children');
%         xdata = [hl.XData t];
%         ydata = [hl.YData I];
%         [xdata, sortI] = sort(xdata);
%         ydata = ydata(sortI);
%         set(hl, 'XData', xdata, 'YData', ydata)
%         
%         hax = subplot(3,1,2);
%         title('Phytoplankton concentration')
%         hl = get(hax, 'Children');
%         xdata = [hl.XData t];
%         ydata = [hl.YData CPhyt];
%         [xdata, sortI] = sort(xdata);
%         ydata = ydata(sortI);
%         set(hl, 'XData', xdata, 'YData', ydata)
%         
%         hax = subplot(3,1,3);
%         title('Light coefficient')
%         hl = get(hax, 'Children');
%         xdata = [hl.XData t];
%         ydata = [hl.YData cl];
%         [xdata, sortI] = sort(xdata);
%         ydata = ydata(sortI);
%         set(hl, 'XData', xdata, 'YData', ydata)
%     else
%         hax = subplot(3,1,1);
%         plot(t,I,'.-')
%         hax.XLim(1) = 0;
%         hax.XLim(2) = Data.nGrowthDays;
%         
%         hax = subplot(3,1,2);
%         plot(t,CPhyt,'.-')
%         hax.XLim(1) = 0;
%         hax.XLim(2) = Data.nGrowthDays;
%         
%         hax = subplot(3,1,3);
%         plot(t,cl,'.-')
%         hax.XLim(1) = 0;
%         hax.XLim(2) = Data.nGrowthDays;
%         hax.YLim(1) = 0;
%         hax.YLim(2) = 1.21;
%     end
% %     drawnow
    
    
end

%%%%%%%%%%%%%


% PRODUCER gain from logistic growth
G = 1 - C*bProducerGuilds/K;
ProducerGrossGrowth = r.*bProducerGuilds.*G;
% ProducerGrossGrowth = r.*bProducerGuilds*G;
gProducerNetGrowth = ProducerGrossGrowth.*(1-s);

% PRODUCER loss to consumption
lProducerConsumption = zeros(GuildInfo.nProducerGuilds, 1);
lProducerConsumption(GuildInfo.iProducerFoodGuildsInProducers) = lossVEC(GuildInfo.iProducerGuildsInFood);

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

lFishNoReproduction = lFishMaintenance; % + lFishConsumption + lFishFishing;
% FISH gained biomass available for growth and reproduction
switch Options.Model.FishReproduction.Version
    case 1
        % gFishBiomassAvailable = max(gFishConsumption - lFishMaintenance,0);
        % gFishBiomassAvailable = max(gFishConsumption ...
        %     - lFishMaintenance ...
        %     - lFishConsumption ...
        %     - lFishFishing,0);
        gFishBiomassAvailable = max(gFishConsumption - lFishNoReproduction, 0);        
    case 2
        sc = Options.Model.FishReproduction.Params;
        gFishBiomassAvailable = gFishConsumption ...
            - (1-log(exp(-(gFishConsumption-lFishNoReproduction)./(sc*lFishNoReproduction))+1)*sc).*lFishNoReproduction;
    case 3
        sc = Options.Model.FishReproduction.Params;
        R1 = sc*gFishConsumption./lFishNoReproduction.*(gFishConsumption <= lFishNoReproduction).*gFishConsumption;
        R2 = sc*(gFishConsumption > lFishNoReproduction).*(2*gFishConsumption-lFishNoReproduction);
        gFishBiomassAvailable = R1+R2;
    case 4
        rho = Options.Model.FishReproduction.Params(1);
        if length(Options.Model.FishReproduction.Params) == 2
            % TODO: Implement model for population of n individuals
        else
            sumPhiL = 1-max(min((lFishNoReproduction./gFishConsumption-rho)/(2*(1-rho)),1),0);
            sumPhiG = sumPhiL*rho+(1-(1-sumPhiL).^2)*(1-rho);
        end
        gFishBiomassAvailable = sumPhiG.*gFishConsumption - sumPhiL.*lFishNoReproduction;
    case 5
        if length(Options.Model.FishReproduction.Params) == 1
            % TODO: Implement model for population of n individuals
        else
            i0_per_n = min(sqrt(1/3*lFishNoReproduction./gFishConsumption),1);
            sumPhiL = 1-i0_per_n;
            sumPhiG = 1-i0_per_n.^3;
        end
        gFishBiomassAvailable = sumPhiG.*gFishConsumption - sumPhiL.*lFishNoReproduction;
    otherwise
        error('Unknown fish reproduction model')
end
gFishBiomassAvailable(isnan(gFishBiomassAvailable)) = 0;

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
% TODO: why InFeeders and not InConsumers ??
gConsumerConsumption = zeros(GuildInfo.nConsumerGuilds, 1);
% gConsumerConsumption(GuildInfo.iNonFishGuildsInFeeders) = gainVEC(GuildInfo.iNonFishGuildsInFeeders);
gConsumerConsumption(GuildInfo.iConsumerGuildsInFeeders) = gainVEC(GuildInfo.iNonFishGuildsInFeeders);

% CONSUMER loss to consumption
lConsumerConsumption(GuildInfo.iConsumerFoodGuildsInConsumers,1) = lossVEC(GuildInfo.iConsumerGuildsInFood);
lConsumerConsumption(GuildInfo.iConsumerNonfoodGuildsInConsumers,1) = 0;

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
% gPOCConsumption = sum(sum(lossMTX.*(1-e)'));
gPOCConsumption = sum(lossVec.*(1-eVec));

% UNDISSOLVED DETRITUS gain from exudations ( = Gross - Net )
gPOCExudation = sum(ProducerGrossGrowth.*s);

% UNDISSOLVED DETRITUS loss from dissolution
% diss_rate = 0.1;
lPOCDissolution = diss_rate*bPOC;

% dPOCdt = + gPOCConsumption ...
%           + gPOCExudation ...
%           - lPOCDissolution;

if Options.isNewVersion
    gPOCConsumerAndFishMaintenance = sum(lConsumerAndFishMaintenance);
    % dPOCdt = + gPOCConsumption ...
    %           + gPOCExudation ...
    %           + gPOCConsumerAndFishMaintenance ...
    %           + respired ...
    %           - lPOCDissolution;
    dXdt(GuildInfo.iPOC) = + gPOCConsumption ...
                            + gPOCExudation ...
                            + gPOCConsumerAndFishMaintenance ...
                            + respired ...
                            - lPOCDissolution;
else
    dXdt(GuildInfo.iPOC) = + gPOCConsumption ...
                            + gPOCExudation ...
                            - lPOCDissolution;
end    

% DISSOLVED DETRITUS gain from dissolution
gDOCDissolution = lPOCDissolution;

% DISSOLVED DETRITUS loss to consumption 

% (DOC eaters)
lDOCConsumption = sum(yxBF(:,GuildInfo.iDOCInFoodGuilds)) / 0.45;
if isempty(lDOCConsumption)
    lDOCConsumption = 0;
end

% (producers)
if Options.isNewVersion
    lDOCProducerGrowth = sum(ProducerGrossGrowth);
else
    lDOCProducerGrowth = 0; 
end

% dDOCdt = + gDOCDissolution ...
%           - lDOCConsumption ...
%           - lDOCProducerGrowth;
dXdt(GuildInfo.iDOC) = + gDOCDissolution ...
                        - lDOCConsumption ...
                        - lDOCProducerGrowth;

% dBdt([GuildInfo.iPOC GuildInfo.iDOC]) = [dPOCdt ; dDOCdt];

% ----------------------------------------------------------------------- %
% CONCATENATE DERIVATIVES OF BIOMASSES, CATCHES, GAIN FISH, GAIN AND LOSS
% ----------------------------------------------------------------------- %

if Options.Outputs.Catch
    % Derivative of fishing
    % dCdt = lFishFishing;
    dXdt(Data.Inds.iC) = lFishFishing;
end

if Options.Outputs.GainFish
    % Derivative of fish reproduction
    % dGFdt = gFishBiomassAvailable./B(GuildInfo.iFishGuilds);
    % dGFdt = lFishReproduction;
    dXdt(Data.Inds.iGF) = lFishReproduction;
end

if Options.Outputs.Gain
    % Derivative of gains
    % dGdt = gainMTX(:);
    dXdt(Data.Inds.iG) = gainMTX(:);
    % dXdt(Data.Inds.iG) = gainVec;
end

if Options.Outputs.Loss
    % Derivative of losses
    % dLdt = lossMTX(:);
    dXdt(Data.Inds.iL) = lossMTX(:);
    % dXdt(Data.Inds.iL) = lossVec;
end

if Options.Outputs.Productivity
    % Derivative of net producer growth
    dXdt(Data.Inds.iP) = gProducerNetGrowth;
end

% if ~all(isreal(dXdt))
%     dXdt
% end