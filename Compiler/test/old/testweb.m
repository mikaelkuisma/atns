function testweb(Data)

if ~isfield(Data.Guilds, 'enable')
    for i = 1:length(Data.Guilds)
        Data.Guilds(i).enable = true;
    end
end
iEnable = find([Data.Guilds.enable]);
Data.Guilds = Data.Guilds(iEnable);
Data.adjacencyMatrix = Data.adjacencyMatrix(iEnable, iEnable);
Data.B0 = Data.B0(iEnable, iEnable);
Data.d = Data.d(iEnable, iEnable);
Data.y = Data.y(iEnable, iEnable);
Data.q = Data.q(iEnable, iEnable);
Data.e = Data.e(iEnable, iEnable);

%
%%% Fish reproduction model
% 1 = original surplus gain based version
% 2 = smoothed version of the original version
% 3 = latest version based on the ratio of gains and losses
% Options.Model.FishReproduction.Version = 1;
% Options.Model.FishReproduction.Version = 2;
% Options.Model.FishReproduction.Params = 0.2;
Options.Model.FishReproduction.Version = 3;
Options.Model.FishReproduction.Params = 0.5;

%
%%% "Closed system"
Options.isNewVersion = false;

%
%%% Producer growth model
Options.intraspecificProducerCompetitionCoefficient = Data.Cii;

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
Options.Outputs.Catch = false;
Options.Outputs.Gain = true;
Options.Outputs.GainDaily = false;
Options.Outputs.Loss = true;
Options.Outputs.SSB = false;
Options.Outputs.JB = false;
Options.Outputs.Productivity = true;
Options.Outputs.ProductivityDaily = true;

%
%%% Length of simulation and growth season, and fishing details
% Data.nGrowthDays = 90;
Data.t_init = 0;
Data.tspan = Data.t_init:Data.nGrowthDays;
Data.ltspan = length(Data.tspan);

Data.burn_in = 0;
Data.start_fishing = Inf;
Data.end_fishing = Inf;
Data.end_recovery = Data.numberOfYears;
Data.cycles = 1:Data.end_recovery;
Data.nYearsFwd = length(Data.cycles);

Data.F = 1;

Data.gear = Gear('lake-vorts');

%
%%% Generate index vectors etc. for guilds
Data = updateGuildInfo(Data);
GI = Data.GuildInfo;

%
%%% ODE options and data preparation
ODEData = compileOdeData(Data, Options);
% odeopt = odeset('RelTol', 1e-3, 'AbsTol', 1e-6); % Default
odeopt = odeset('RelTol', 1e-5, 'AbsTol', 1e-6);
odeopt = odeset(odeopt, 'NonNegative', 1:GI.nGuilds);
ODEData = addIndices(ODEData, GI, Options);

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
    
    [~,X] = ode23(@(t,X)atn_ode(t,X,ODEData,Options), ...
        Data.tspan,Xinit,odeopt);
    
    if ~isreal(X) || any(any(isnan(X)))
        error('Differential eqution solver returned non real biomasses. Check model parameters.');
    end
	
    if ~Options.isNewVersion
        %%%%%% Fix for constraining the biomass of dissolved detritus %%%%%%%%
        bDOC_max = 1e6;
        X(end,GI.iDOC) = min([X(end,GI.iDOC) bDOC_max]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    Xend = X(end,:)';
    
    [Binit, OUT] = reproductionAndAging(Xend, ODEData.Inds, Data.Guilds, GI, Options.Outputs);
    Xend(ODEData.Inds.iB) = Binit;
    
    Results = updateResultsStruct(Results,Xend,ODEData.Inds,OUT,X,cycle,ODEData,GI,Options);

    cpuTime(cycle) = toc;
    
    %
    tt = (cycle-1)*Data.ltspan+1:cycle*Data.ltspan;
    
    if false
        figure(991)
        set(gcf, 'units', 'normalized')
        set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
        clf
        Is = [GI.iPOC GI.iDOC];
        for i = 1:length(Is)
            subplot(1,2,i)
            I = Is(i);
            hold on
            plot(Results.allbiomasses(I, tt), 'linewidth', 1)
            title(Data.Guilds(I).label)
            box off
            set(gca,'tickdir','out')
        end
    end
    
    if false
        figure(992)
        set(gcf, 'units', 'normalized')
        set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
        clf
        Is = GI.iProducerGuilds;
        for i = 1:length(Is)
            subplot(3,3,i)
            I = Is(i);
            hold on
            plot(Results.allbiomasses(I, tt), 'linewidth', 1)
            title(Data.Guilds(I).label)
            box off
            set(gca,'tickdir','out')
        end
    end

    if false
    figure(990)
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    clf
    subplot(1,3,1)
    plot(sum(Results.allbiomasses(Is, tt)), 'linewidth', 1)
    title('Producer total biomass')
    end
end
disp(['Simulation finished. The simulation took ' num2str(sum(cpuTime)) ' seconds.'])

testPlotBiomasses(Results, Data)
testPlotFishLosses(Results, Data)
testPlotFishGains(Results, Data)
