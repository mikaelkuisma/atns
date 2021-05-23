%%% TODO 1
%
% Kcvs = [0.05 0.10 0.20];
% Fs = [0.5 0.75 1];
% gears = {'small-mesh net', 'large-mesh net'};
%
% for Kcv = Kcvs
%    for F = Fs
%       for gear = gears
%
%       end
%    end
% end
%
%%% TODO 2
% 
% vrt K version 4
%
%


%%% Set directory and filename for results
ResultOptions.Directory = sprintf('testresults/%s/',datestr(now,'YYYY-mm-DD_HH-MM-ss'));
if ~exist(ResultOptions.Directory,'dir')
    mkdir(ResultOptions.Directory)
end
ResultOptions.File = sprintf('results.txt');

%
%%% Fish reproduction model
% 1 = original surplus gain based version
% 2 = smoothed version of the original version
% 3 = latest version based on the ratio of gains and losses
% Options.Model.FishReproduction.Version = 1;
%Options.Model.FishReproduction.Version = 2;
%Options.Model.FishReproduction.Params = 0.2;
Options.Model.FishReproduction.Version = 3;
Options.Model.FishReproduction.Params = 0.5;

%
%%% Import ecosystem model (choose based on fish reproduction model)
% load('Data\1_LakeConstance.mat','Data')
%load('Data\1_LakeConstance_v2.mat','Data')
% load('Data\1_LakeConstance_v3.mat','Data')
% load('Data\1_LakeConstance_new.mat','Data')
load('Data\1_LakeConstance_new2.mat','Data')
% load('Data\4_LakeVorts.mat','Data')
% load('Data\4_LakeVorts_withWeakLinks','Data')
% load('Data\4_LakeVorts_withWeakLinks_WO_AMU','Data')
% load('Data\4_LakeVorts_WO_AMU','Data')
%

% Data.B0(28,20) = 1500;
% Data.d(28,20) = 1e-4;

% Data.d(31,23) = Data.d(30,23);
% Data.d(32,23) = Data.d(30,23);
% Data.d(31,28) = Data.d(30,28);
% Data.d(32,28) = Data.d(30,28);
% % 
% Data.B0(31,23) = Data.B0(30,23);
% Data.B0(32,23) = Data.B0(30,23);
% Data.B0(31,28) = Data.B0(30,28);
% Data.B0(32,28) = Data.B0(30,28);

% Data.q(:,20) = 2;
% 
% Data.d(:,20) = Data.d(:,21);

%
% Data.d(23:32, 22) = 0.01;

%%% HNF as prey (B0 = 1500)

% Data.B0(12,10) = 3000;
% Data.B0(13,10) = 3000;
% Data.B0(14,10) = 3000;
% Data.B0(15,10) = 3000;
% Data.B0(16,10) = 3000;
% Data.B0(17,10) = 3000;
% Data.B0(18,10) = 3000;
% Data.B0(19,10) = 3000;
% Data.B0(20,10) = 3000;
% Data.B0(21,10) = 3000;

% Data.B0(12,10) = 4500;
% Data.B0(13,10) = 4500;
% Data.B0(14,10) = 4500;
% Data.B0(15,10) = 4500;
% Data.B0(16,10) = 4500;
% Data.B0(17,10) = 4500;
% Data.B0(18,10) = 4500;
% Data.B0(19,10) = 4500;
% Data.B0(20,10) = 4500;
% Data.B0(21,10) = 4500;

% Data.q = 3*ones(size(Data.q));

%%%

%%% "Closed system"
Options.isNewVersion = false;


%
%%% Length of simulation and growth season, and fishing details
Data.nGrowthDays = 240;
Data.t_init = 0;
Data.tspan = Data.t_init:Data.nGrowthDays;
Data.ltspan = length(Data.tspan);

Data.end_burnin = 10;
Data.start_fishing = 61;
Data.end_fishing = 110;
Data.end_recovery = 160;
y0 = 50;
% Data.end_burnin = 5;
% Data.start_fishing = 15;
% Data.end_fishing = 25;
% Data.end_recovery = 35;
% y0 = 10;


Data.cycles = 1:Data.end_recovery;
Data.nYearsFwd = length(Data.cycles);


%
%%% Producer growth model
Options.intraspecificProducerCompetitionCoefficient = 2;
% Data.K = basalProductionCarryingCapacityModel('Constant',540000);
Data.K = basalProductionCarryingCapacityModel('White noise', 540000, 54000);
% Data.K = basalProductionCarryingCapacityModel('AR(1)',540000,10000,0.8);

%%% Producer growth model within growth season
% 1 = original constant K model
% 2 = first half of sinusoidal wave K model
% 3 = Antti's try to follow Boit et al. 2012 "abiotic forcing"
% 4 = New K model which has same level as 1 & 2 and peaks at 120 days
% (in the middle of growth season)
% 5 = Mirror of K4, i.e. seasonally increasing K
% 6 = Mirror of K2 = U-shaped seasonal K (cf. Uszko et al. 2017

Options.Model.GrowthSeason.K.Version = 1;
% Options.Model.GrowthSeason.K.Version = 2;
% Options.Model.GrowthSeason.K.Params = 0.25;
%Options.Model.GrowthSeason.K.Version = 3;
%Options.Model.GrowthSeason.Params.z = 0.1; % Decay component
%Options.Model.GrowthSeason.Params.tmax = 120; % originally 110 (beginning of summer)

% Options.Model.GrowthSeason.K.Version = 4;
% Options.Model.GrowthSeason.Params.z = 0.45; % Decay component
% Options.Model.GrowthSeason.Params.tmax = 235; % half-way of growth season of length 240 days
% Options.Model.GrowthSeason.Params.kavg = 0.5; % average for K coefficient
% Options.Model.GrowthSeason.Params.d = 0.5; % sets range (max and min) for k

% NOTE1: IF kavg = 0.5 & d = 0.5, the results should be the same as with K.Version = 3
% NOTE2: originally d = 0.5, but then limited to d = 0.25
%Options.Model.GrowthSeason.K.Version = 5;
%Options.Model.GrowthSeason.Params.z = 0.1; % Decay component
%Options.Model.GrowthSeason.Params.tmax = 120; % half-way of growth season of length 240 days
%Options.Model.GrowthSeason.Params.kavg = 1; % average for K coefficient
%Options.Model.GrowthSeason.Params.d = 0.25; % sets range (max and min) for k
% Options.Model.GrowthSeason.K.Version = 6;
% Options.Model.GrowthSeason.K.Params = 0.25;

%%% Density (alias light) dependent producer growth rate
% 1 = original constant autotrophs ri model
% 2 = Antti's try to follow Boit et al. 2012 considering 
% light extinction as a function of epilimnion depth and self-shading
Options.Model.GrowthSeason.AutotrophR.Version = 1;
% Options.Model.GrowthSeason.AutotrophR.Version = 2;
% I_avg = 150+20;
% Options.Model.GrowthSeason.AutotrophR.Params.I = ...
%     @(t)I_avg+(100*(0.8*(2*sin(pi/Data.nGrowthDays*t)-1)));
% Options.Model.GrowthSeason.AutotrophR.Params.I = ...
%     @(t)150;
% Options.Model.GrowthSeason.AutotrophR.Params.I0 = 20; % Half sat.irradiance (W/m2)
% Options.Model.GrowthSeason.AutotrophR.Params.h = 20; % epilimnion depth(m)
% Options.Model.GrowthSeason.AutotrophR.Params.chi1 = 0.1; % light extinction coefficient (1/m)
% Options.Model.GrowthSeason.AutotrophR.Params.chi2 = 0.0001; % self-shading coefficient 
% Options.Model.GrowthSeason.AutotrophR.Params.chi2 = 0.000002; % self-shading coefficient 
% Options.Model.GrowthSeason.AutotrophR.Params.chi2 = 1e-12; % self-shading coefficient 
% Options.Model.GrowthSeason.AutotrophR.Params.sc = 1/0.8824;
% Originally (m2/gC) --> should be here given as m3/ugC)



%
%%% Outputs
Options.Outputs.Biomass = true; % can't imagine why this could be false though
Options.Outputs.GainFish = true; % this is essential for fish reproduction
% Set these to false if they are not needed to speed up computation
Options.Outputs.AllBiomasses = true;
Options.Outputs.Catch = true;
Options.Outputs.Gain = true;
Options.Outputs.GainDaily = false;
Options.Outputs.Loss = true;
Options.Outputs.SSB = false;
Options.Outputs.JB = false;
Options.Outputs.Productivity = true;
Options.Outputs.ProductivityDaily = true;


Data.F = 0.75;

% Data.gear = Gear('rectangle', 'interval', [22.1 22.3]);
% Data.gear = Gear('lake-vorts');
Data.gear = Gear('small-mesh net');
% Data.gear = Gear('large-mesh net');
% Data.propRelease = [0 0 0 0 0.5 0 0 0 0 0.5]; % the proportion of fish released (fyke net)
% Data.gear = Gear('fyke net', Data.propRelease);
% Data.gear = Gear('hatchery-test');
% Data.gear = Gear('stochasticity-simulations');
% Data.gear = Gear('none');

% Data.Guilds(25).catchable = true;
% Data.Guilds(26).catchable = true;
% Data.Guilds(27).catchable = true;
% 
% Data.Guilds(30).catchable = true;
% Data.Guilds(31).catchable = true;
% Data.Guilds(32).catchable = true;

%
%%% Generate index vectors etc. for guilds
Data = updateGuildInfo(Data);
GI = Data.GuildInfo;

%
%%% ODE options and data preparation
ODEData = compileOdeData(Data,Options);

% ODEData.omegaVec(:) = 1;

odeopt = odeset('RelTol',1e-3,'AbsTol',1e-6); % Default
% odeopt = odeset('RelTol',1e-9,'AbsTol',1e-10);
ODEData = addIndices(ODEData,GI,Options);

%
%%% Initialize simulation
Binit = vertcat(Data.Guilds.binit);
cpuTime = zeros(1,Data.nYearsFwd);

%
%%% Initialize results
Results = initializeResultStruct(GI,Data.nYearsFwd,Data.ltspan,Options.Outputs);

%
%%% Simulation
for cycle = Data.cycles
    tic
    avgCpuTime = mean(cpuTime(1:cycle-1));
    timeLeftEst = round((Data.end_recovery-cycle+1)*avgCpuTime);
    
    fprintf('Cycle %i/%i starting. Estimated time left %i seconds\n', ...
       cycle, Data.end_recovery, timeLeftEst);
    
    if (cycle > (Data.start_fishing-1) && cycle < (Data.end_fishing+1))
        ODEData.hmax = Data.F/ODEData.ltspan;
    else
        ODEData.hmax = 0;
    end
    ODEData.E = ODEData.hmax*Data.gear.selectivity(Data.Guilds(GI.iFishGuilds));

    ODEData.year = cycle;

    Xinit = initialValueVector(Binit, GI, Options.Outputs);
    
    % Producer carrying capacity as a function of dissolved detritus biomass
    %ODEData.K.values(ODEData.year) = basalProductionCarryingCapacity(Binit(GI.iDOC2), ...
    %    ODEData.K.mean, Options.isNewVersion);

    [~,X] = ode23(@(t,X)atn_ode(t,X,ODEData,Options), ...
        Data.tspan,Xinit,odeopt);
    
    % % We can restrict the solution to be non-negative to avoid errors.
    % options = odeset('NonNegative',1:GI.nGuilds);
    % [~,X] = ode23(@(t,X)atn_ode_biomass_catch_gainfish_gain_loss_fast(t,X,ODEData), ...
    %     tspan,[Binit ; Cinit ; GFinit ; Ginit ; Linit],options);
    
    if ~isreal(X) || any(any(isnan(X)))
        error('Differential eqution solver returned non real biomasses. Check model parameters.');
    end
	
    if ~Options.isNewVersion
        %%%%%% Fix for constraining the biomass of dissolved detritus %%%%%%%%
        bDOC2_max = 1e6;
        X(end,GI.iDOC2) = min([X(end,GI.iDOC2) bDOC2_max]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    Xend = X(end,:)';
    
    [Binit, OUT] = reproductionAndAging(Xend, ODEData.Inds, Data.Guilds, GI, Options.Outputs);
    Xend(ODEData.Inds.iB) = Binit;
    
    Results = updateResultsStruct(Results,Xend,ODEData.Inds,OUT,X,cycle,ODEData,GI,Options);

    cpuTime(cycle) = toc;
end
disp(['Simulation finished. The simulation took ' num2str(sum(cpuTime)) ' seconds.'])

% saveResults(Results,ResultOptions,GI);

%%
% close all
% plotDensity(Results, Data, 8:10, 1:241)
% %plotGain(Results, Data, 10, [], 1:241)
% plotGainDensity(Results, Data, 10, [], 1:241)
% %plotGain(Results, Data, [], 10, 1:241)
% plotGainDensity(Results, Data, [], 10, 1:241)
%%
plotConsumerGains
%%
plotFishGains
%%
% plotFishCohorts
% 
% plotReproductiveOutputPerch
% plotReproductiveOutputWhitefish
%%
plotDensities
%%
% plotRelativeCVs
plotRelativeCVs_b_d
% plotRelativeStds
% plotRelativeMeans