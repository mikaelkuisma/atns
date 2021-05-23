%%
ResultOptions.Directory = sprintf('./Results/LC_stocha/%s/',datestr(now,'YYYY-mm-DD_HH-MM-ss'));
if ~exist(ResultOptions.Directory,'dir')
    mkdir(ResultOptions.Directory)
end

%%
% parallelID = 1;
% replicateIDs = 10*(parallelID-1)+(1:10);
replicateIDs = 1:100;
% replicateIDs = 1;
nRep = length(replicateIDs);

%% LAKE CONSTANCE
load('Data\1_LakeConstance.mat','Data')

%%
propRelease = 0.5; % the proportion of fish released (fyke net)

%%

% Options.isNewVersion = true;
Options.isNewVersion = false;

%%

Options.intraspecificProducerCompetitionCoefficient = 2.0225;

%%

Options.Outputs.Biomass = true; % can't imagine why this could be false though
Options.Outputs.GainFish = true; % this is essential for fish reproduction
% Set these to false if they are not needed to speed up computation
Options.Outputs.AllBiomasses = true;
Options.Outputs.Catch = false;
Options.Outputs.Gain = false;
Options.Outputs.Loss = false;
Options.Outputs.SSB = false;
Options.Outputs.JB = false;

%%

nGrowthDays = 90;
t_init = 0;
tspan = t_init:nGrowthDays;
Data.ltspan = length(tspan);

start_fishing = 51;
end_fishing = 100;
end_recovery = 100;
cycles = 1:end_recovery;
Data.nYearsFwd = length(cycles);

F = 0.5;

% gearStr = 'small-mesh net';
% gearStr = 'large-mesh net';
% gearStr = 'fyke net';
% gearStr = 'hatchery-test';
% gearStr = 'none';
% gearStr = 'stochasticity-simulations';
gear = Gear('stochasticity-simulations');

Ksdsp = [0.05 0.10 0.15 0.20];
Kacs = [0 0.4 -0.4];
nKsds = length(Ksdsp);
nKacs = length(Kacs);

Ktype = 'AR(1)';
Kmean = 540000;

Data = updateGuildInfo(Data);
Data.hmax = F/Data.ltspan;

GI = Data.GuildInfo;

Data = addIndices(Data,GI,Options);

isFailed = false;
for iKsds = 1:nKsds
    for iKacs = 1:nKacs
        for iRep = 1:nRep
            
            isReady = false;
            while ~isReady
                Data.K = basalProductionCarryingCapacityModel(Ktype,Kmean,Ksdsp(iKsds)*Kmean,Kacs(iKacs));
                
                ODEData = compileOdeData(Data,Options);
                
                Results = initializeResultStruct(GI,Data.nYearsFwd,Data.ltspan,Options.Outputs);
                
                Binit = vertcat(ODEData.Guilds.binit);
                cpuTime = zeros(1,Data.nYearsFwd);
                
                for cycle = cycles
                    tic
                    %avgCpuTime = mean(cpuTime(1:cycle-1));
                    %timeLeftEst = round((end_recovery-cycle+1)*avgCpuTime);
                    %
                    %fprintf('Cycle %i/%i starting. Estimated time left %i seconds\n', ...
                    %    cycle, end_recovery, timeLeftEst);
                    
                    if (cycle > (start_fishing-1) && cycle < (end_fishing+1))
                        ODEData.E = gear.selectivity(ODEData.Guilds(GI.iFishGuilds))*ODEData.hmax;
%                         ODEData.E = selective_fishery(ODEData,gearStr);
%                         if strcmp(gearStr,'fyke net')
%                             oldFishInds = find([ODEData.Guilds(GI.iAdultFishGuilds).age] == 4);
%                             ODEData.E(oldFishInds) = ODEData.E(oldFishInds)*(1-propRelease);
%                         end
                    else
                        ODEData.E = zeros(GI.nFishGuilds,1);
                    end
                    
                    ODEData.year = cycle;
                    
                    Xinit = initialValueVector(Binit, GI, Options.Outputs);
                    
                    % Producer carrying capacity as a function of dissolved detritus biomass
                    ODEData.K.values(ODEData.year) = basalProductionCarryingCapacity(Binit(GI.iDOC2), ...
                        ODEData.K.values(ODEData.year), Options.isNewVersion);
                    
                    [~,X] = ode23(@(t,X)atn_ode(t,X,ODEData,Options), ...
                        tspan,Xinit);
                    
                    %     % We can restrict the solution to be non-negative to avoid errors.
                    %     options = odeset('NonNegative',1:GI.nGuilds);
                    %     [~,X] = ode23(@(t,X)atn_ode_biomass_catch_gainfish_gain_loss_fast(t,X,ODEData), ...
                    %         tspan,[Binit ; Cinit ; GFinit ; Ginit ; Linit],options);
                    
                    
                    if ~isreal(X) || any(any(isnan(X)))
                        warning('Differential eqution solver returned non real biomasses. Check model parameters.');
                        isFailed = true;
                        break
                    end
                    
                    if any(any(isinf(X)))
                        warning('Differential eqution solver returned Inf. Trying again.');
                        isFailed = true;
                        break
                    end
                    
                    if ~Options.isNewVersion
                        %%%%%% Fix for constraining the biomass of dissolved detritus %%%%%%%%
                        bDOC2_max = 1e6;
                        X(end,GI.iDOC2) = min([X(end,GI.iDOC2) bDOC2_max]);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                    
                    Xend = X(end,:)';
                    
                    [Binit, OUT] = reproductionAndAging(Xend, Data.Inds, Data.Guilds, GI, Options.Outputs);
                    Xend(Data.Inds.iB) = Binit;
                    
                    Results = updateResultsStruct(Results,Xend,Data.Inds,OUT,X,cycle,Data,GI,Options);
                    
                    cpuTime(cycle) = toc;
                end
                if isFailed
                    isReady = false;
                else
                    isReady = true;
                end
            end
            fprintf('Simulation %i.%i.%i/%i.%i.%i finished. The simulation took %i seconds.\n', ...
                iKsds,iKacs,iRep,nKsds,nKacs,nRep,round(sum(cpuTime)))
            
            repStr = '000000';
            repStr = [repStr num2str(replicateIDs(iRep))]; %#ok<AGROW>
            repStr = repStr(end-2:end);
            
            KsdStr = '000000';
            KsdStr = [KsdStr num2str(Ksdsp(iKsds)*100)]; %#ok<AGROW>
            KsdStr = KsdStr(end-2:end);
            
            KacStr = '000000';
            KacStr = [KacStr num2str(abs(Kacs(iKacs))*100)]; %#ok<AGROW>
            KacStr = KacStr(end-2:end);
            if Kacs(iKacs) < 0
                KacStr = ['-' KacStr]; %#ok<AGROW>
            end
            ResultOptions.File = sprintf('results_%s_%s_%s.txt',KsdStr,KacStr,repStr);

            saveResults(Results,ResultOptions,GI);
            
        end
    end
end
