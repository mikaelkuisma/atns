function Results = test_suite_old_run(DataFile, odeopt)

[filepath,DataFileName,ext] = fileparts(DataFile)
global evaluations
evaluations = 0;
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
%Options.Model.FishReproduction.Version = 1;
%Options.Model.FishReproduction.Version = 2;
%Options.Model.FishReproduction.Params = 0.2;
Options.Model.FishReproduction.Version = 3;
Options.Model.FishReproduction.Params = 0.5;

%
%%% Import ecosystem model
load(DataFile, 'Data')

%
%%% Save network properties to file
adjacencyMatrixToFile(sprintf('%s%s_%s.txt', ResultOptions.Directory, DataFileName, 'links'), Data.adjacencyMatrix)
guildLabelsToFile(sprintf('%s%s_%s.txt', ResultOptions.Directory, DataFileName, 'labels'), Data.Guilds)
guildColorsToFile(sprintf('%s%s_%s.txt', ResultOptions.Directory, DataFileName, 'colors'), Data.Guilds)
trophicLevelsToFile(sprintf('%s%s_%s.txt', ResultOptions.Directory, DataFileName, 'TL'), Data.adjacencyMatrix)

%
%%% "Closed system"
Options.isNewVersion = false;

%
%%% Producer growth model
Options.intraspecificProducerCompetitionCoefficient = 2;
Data.K = basalProductionCarryingCapacityModel('Constant',540000);
%Data.K = basalProductionCarryingCapacityModel('White noise',540000,40000);
%Data.K = basalProductionCarryingCapacityModel('AR(1)',540000,40000,0.8);

%%% Producer growth model within growth season
% 1 = original constant K model
% 2 = first half of sinusoidal wave K model
Options.Model.GrowthSeason.K.Version = 1;
%Options.Model.GrowthSeason.K.Version = 2;
%Options.Model.GrowthSeason.K.Params = 0.25;


%
%%% Outputs
Options.Outputs.Biomass = true; % can't imagine why this could be false though
Options.Outputs.GainFish = true; % this is essential for fish reproduction
% Set these to false if they are not needed to speed up computation
Options.Outputs.AllBiomasses = true;
Options.Outputs.Catch = true;
Options.Outputs.Gain = true;
Options.Outputs.Loss = true;
Options.Outputs.SSB = false;
Options.Outputs.JB = false;
Options.Outputs.Productivity = true;
Options.Outputs.ProductivityDaily = true;

%
%%% Length of simulation and growth season, and fishing details
Data.nGrowthDays = 90;
Data.t_init = 0;
Data.tspan = Data.t_init:Data.nGrowthDays;
Data.ltspan = length(Data.tspan);

Data.start_fishing = 101;
Data.end_fishing = 150;
Data.end_recovery = 30;
Data.cycles = 1:Data.end_recovery;
Data.nYearsFwd = length(Data.cycles);

Data.F = 1;

Data.gear = Gear('lake-vorts');
% Data.gear = Gear('small-mesh net');
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
%odeopt = odeset('RelTol',1e-3,'AbsTol',1e-6); % Default
%odeopt = odeset('RelTol',1e-9,'AbsTol',1e-10);
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
        bDOC_max = 1e6;
        X(end,GI.iDOC) = min([X(end,GI.iDOC) bDOC_max]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    Xend = X(end,:)';
    
    [Binit, OUT] = reproductionAndAging(Xend, ODEData.Inds, Data.Guilds, GI, Options.Outputs);
    Xend(ODEData.Inds.iB) = Binit;
    
    Results = updateResultsStruct(Results,Xend,ODEData.Inds,OUT,X,cycle,ODEData,GI,Options);

    cpuTime(cycle) = toc;
end
disp(['Simulation finished. The simulation took ' num2str(sum(cpuTime)) ' seconds.'])
Results.evaluations = evaluations;
% saveResults(Results,ResultOptions,GI);