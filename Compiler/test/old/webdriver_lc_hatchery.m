%% LAKE CONSTANCE
load('Data\1_LakeConstance.mat','Data')

%%
% resultdirstr = sprintf('P:/h575/grp_aquaticecosystems/ATN/ATN_LCHatchery_results/%s/',datestr(now,'YYYY-mm-DD_HH-MM-ss'));
ResultOptions.Directory = sprintf('ATN_LCHatchery_results/%s/',datestr(now,'YYYY-mm-DD_HH-MM-ss'));
if ~exist(ResultOptions.Directory,'dir')
    mkdir(ResultOptions.Directory)
end

%%
propRelease = 0.5;

%%
% Specify here which adult fish guilds are catchable
Data.Guilds(25).catchable = true; %Whi2
Data.Guilds(26).catchable = true; %Whi3
Data.Guilds(27).catchable = true; %Whi4
Data.Guilds(30).catchable = true; %Per2
Data.Guilds(31).catchable = true; %Per3
Data.Guilds(32).catchable = true; %Per4

%% LAKE OULUNJÄRVI
% load('Data\LakeOulunjarvi.mat','Data')
%
% % Specify here which adult fish guilds are catchable
% Data.Guilds(25).catchable = false; %Per2
% Data.Guilds(26).catchable = false; %Per3
% Data.Guilds(27).catchable = false; %Per4
% Data.Guilds(30).catchable = false; %Ppe2
% Data.Guilds(31).catchable = false; %Ppe3
% Data.Guilds(32).catchable = false; %Ppe4
% Data.Guilds(35).catchable = false; %Sme2
% Data.Guilds(36).catchable = false; %Sme3
% Data.Guilds(37).catchable = false; %Sme4
% Data.Guilds(40).catchable = false; %Roa2
% Data.Guilds(41).catchable = false; %Roa3
% Data.Guilds(42).catchable = false; %Roa4

%%
% Options.isNewVersion = true;
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

start_fishing = 121;
end_fishing = 220;
end_recovery = 220;
cycles = 1:end_recovery;
Data.nYearsFwd = length(cycles);

F = 0.75;

% gearStr = 'small-mesh net';
% gearStr = 'large-mesh net';
% gearStr = 'fyke net';
% gearStr = 'hatchery-test';
gear = Gear('hatchery-test');

Data.K = basalProductionCarryingCapacityModel('Constant',540000);
%Data.K = basalProductionCarryingCapacityModel('White noise',540000,40000);
%Data.K = basalProductionCarryingCapacityModel('AR(1)',540000,40000,0.8);

Data = updateGuildInfo(Data);
Data.hmax = F/Data.ltspan;

Data = compileOdeData(Data,Options);

GI = Data.GuildInfo;

Data = addIndices(Data,GI,Options);

Binit = vertcat(Data.Guilds.binit);
cpuTime = zeros(1,Data.nYearsFwd);

whi_hatchery = 0:25:400;    % p1
per_hatchery = 0:25:400;    % p2

np1 = length(whi_hatchery);
np2 = length(per_hatchery);

%%

for ip1 = 1:np1
    
    Data.hatchery(1) = whi_hatchery(ip1);
    
    for ip2 = 1:np2
        
        Data.hatchery(6) = per_hatchery(ip2);
        
        ResultOptions.File = sprintf('data_whi_%03d_per_%03d.txt',whi_hatchery(ip1),per_hatchery(ip2));
        
        Results = initializeResultStruct(GI,Data.nYearsFwd,Data.ltspan,Options.Outputs);
        
        for cycle = cycles
            tic
            %avgCpuTime = mean(cpuTime(1:cycle-1));
            %timeLeftEst = round((end_recovery-cycle+1)*avgCpuTime);
            %
            %fprintf('Cycle %i/%i starting. Estimated time left %i seconds\n', ...
            %    cycle, end_recovery, timeLeftEst);
            
            if (cycle > (start_fishing-1) && cycle < (end_fishing+1))
                Data.E = gear.selectivity(Data.Guilds(GI.iFishGuilds))*Data.hmax;
%                 Data.E = selective_fishery(Data,gearStr);
%                 if strcmp(gearStr,'fyke net')
%                     oldFishInds = find([Data.Guilds(GI.iAdultFishGuilds).age] == 4);
%                     Data.E(oldFishInds) = Data.E(oldFishInds)*(1-propRelease);
%                 end
            else
                Data.E = zeros(GI.nFishGuilds,1);
            end
            
            Data.year = cycle;
            
            Xinit = initialValueVector(Binit, GI, Options.Outputs);
            
            % Producer carrying capacity as a function of dissolved detritus biomass
            Data.K.values(Data.year) = basalProductionCarryingCapacity(Binit(GI.iDOC2), ...
                Data.K.mean, Options.isNewVersion);            
            
            [~,X] = ode23(@(t,X)atn_ode(t,X,Data,Options), ...
                tspan,Xinit);
            
            if ~isreal(X) || any(any(isnan(X)))
                warning('Differential eqution solver returned non real biomasses. Check model parameters.');
            end
            
            if ~Options.isNewVersion
                %%%%%%% Fix for constraining the biomass of dissolved detritus %%%%%%%%
                bDOC2_max = 1e6;
                X(end,GI.iDOC2) = min([X(end,GI.iDOC2) bDOC2_max]);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            
            Xend = X(end,:)';
            
            [Binit, OUT] = reproductionAndAging(Xend, Data.Inds, Data.Guilds, GI, Options.Outputs);
            Xend(Data.Inds.iB) = Binit;
            
            Results = updateResultsStruct(Results,Xend,Data.Inds,OUT,X,cycle,Data,GI,Options);
            
            cpuTime(cycle) = toc;
        end
        disp(['Simulation ' num2str(ip1) '.' num2str(ip2) '/' num2str(np1) '.' num2str(np2) ...
            ' finished. The simulation took ' num2str(sum(cpuTime)) ' seconds.'])

        saveResults(Results,ResultOptions,GI);
        
    end
end
