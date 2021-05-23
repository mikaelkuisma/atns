%% LAKE CONSTANCE

load('Data\1_LakeConstance.mat','Data')

%%
ResultOptions.Directory = sprintf('testresults/%s/',datestr(now,'YYYY-mm-DD_HH-MM-ss'));
if ~exist(ResultOptions.Directory,'dir')
    mkdir(ResultOptions.Directory)
end

%%
propRelease = [0 0 0 0 0.5 0 0 0 0 0.5]; % the proportion of fish released (fyke net)

%% LAKE OULUNJ?RVI
% load('Data\1_LakeOulunjarvi.mat','Data')


%%

% Data.Options.isNewVersion = true;
Options.isNewVersion = false;

%%

Options.intraspecificProducerCompetitionCoefficient = 2;

%%

Options.Outputs.Biomass = true; % can't imagine why this could be false though
Options.Outputs.GainFish = true; % this is essential for fish reproduction
% Set these to false if they are not needed to speed up computation
Options.Outputs.AllBiomasses = true;
Options.Outputs.Catch = true;
Options.Outputs.Gain = true;
Options.Outputs.Loss = true;
Options.Outputs.SSB = true;
Options.Outputs.JB = true;

%%
nGrowthDays = 90;
t_init = 0;
tspan = t_init:nGrowthDays;
Data.ltspan = length(tspan);

start_fishing = 151;
end_fishing = 200;
end_recovery = 300;
cycles = 1:end_recovery;
Data.nYearsFwd = length(cycles);

F = 0.5;

% gear = Gear('small-mesh net');
gear = Gear('large-mesh net');
% gear = Gear('fyke net', propRelease);
% gear = Gear('hatchery-test');
% gear = Gear('stochasticity-simulations');
% gear = Gear('none');


Data.K = basalProductionCarryingCapacityModel('Constant',540000);
%Data.K = basalProductionCarryingCapacityModel('White noise',540000,40000);
%Data.K = basalProductionCarryingCapacityModel('AR(1)',540000,40000,0.8);

Data = updateGuildInfo(Data);

ODEData = compileOdeData(Data,Options);
odeopt = odeset('RelTol',1e-3,'AbsTol',1e-6); % Default
% odeopt = odeset('RelTol',1e-9,'AbsTol',1e-10);

GI = Data.GuildInfo;

ODEData = addIndices(ODEData,GI,Options);

Binit = vertcat(Data.Guilds.binit);
cpuTime = zeros(1,Data.nYearsFwd);

ResultOptions.File = sprintf('results.txt');

Results = initializeResultStruct(GI,Data.nYearsFwd,Data.ltspan,Options.Outputs);

for cycle = cycles
    tic
    avgCpuTime = mean(cpuTime(1:cycle-1));
    timeLeftEst = round((end_recovery-cycle+1)*avgCpuTime);
    
    fprintf('Cycle %i/%i starting. Estimated time left %i seconds\n', ...
       cycle, end_recovery, timeLeftEst);
    
    if (cycle > (start_fishing-1) && cycle < (end_fishing+1))
        ODEData.hmax = F/ODEData.ltspan;
    else
        ODEData.hmax = 0;
    end
    ODEData.E = ODEData.hmax*gear.selectivity(Data.Guilds(GI.iFishGuilds));

    ODEData.year = cycle;

    Xinit = initialValueVector(Binit, GI, Options.Outputs);
    
    % Producer carrying capacity as a function of dissolved detritus biomass
    ODEData.K.values(ODEData.year) = basalProductionCarryingCapacity(Binit(GI.iDOC2), ...
        ODEData.K.mean, Options.isNewVersion);

    [~,X] = ode23(@(t,X)atn_ode_3(t,X,ODEData,Options), ...
        tspan,Xinit,odeopt);
    
%     % We can restrict the solution to be non-negative to avoid errors.
%     options = odeset('NonNegative',1:GI.nGuilds);
%     [~,X] = ode23(@(t,X)atn_ode_biomass_catch_gainfish_gain_loss_fast(t,X,ODEData), ...
%         tspan,[Binit ; Cinit ; GFinit ; Ginit ; Linit],options);
    
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