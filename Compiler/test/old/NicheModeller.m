function [Data_updated]= NicheModeller(nSpecies)

if nargin < 1
    nSpecies = 25;
end
% a function that creates a random, Niche-type foodweb and runs it by using
% Tommy Peraelae's "Fishing Game" code. 
% Parameters:   nSpecies = number of species in the web
%               noiseType = value of the noise component (red, blue, white)

[Data] = generateRandomNetwork(nSpecies);

save('Data\testi_seed10_20082019.mat','Data')

[rows, colms] = size(Data.adjacencyMatrix);
% calculating a collection of web properties before dynamical modelling
% work in progress...

%load('Data\1_LakeConstance.mat','Data')

% Tommy's "webdriver.m" just copied below:

ResultOptions.Directory = sprintf('testresults/%s/',datestr(now,'YYYY-mm-DD_HH-MM-ss'));
if ~exist(ResultOptions.Directory,'dir')
    mkdir(ResultOptions.Directory)
end

%%
propRelease = 0.5; % the proportion of fish released (fyke net)

%% LAKE OULUNJ�RVI
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

start_fishing = 51;
end_fishing = 100;
end_recovery = 100;
cycles = 1:end_recovery;
Data.nYearsFwd = length(cycles);

F = 0.75;

% gear = Gear('small-mesh net');
gear = Gear('large-mesh net');
% gear = Gear('fyke net', propRelease);
% gear = Gear('hatchery-test');
% gear = Gear('stochasticity-simulations');
% gear = Gear('none');

Data.K = basalProductionCarryingCapacityModel('Constant',540000);
%Data.K = basalProductionCarryingCapacityModel('White noise',540000,40000);
%Data.K = basalProductionCarryingCapacityModel('AR(1)',540000,40000,-0.8);

Data = updateGuildInfo(Data);
Data.hmax = F/Data.ltspan;

ODEData = compileOdeData(Data,Options);
%odeopt = odeset('RelTol',1e-9,'AbsTol',1e-10);  % original, commented out
%6.7.2018
odeopt = odeset('RelTol',1e-7,'AbsTol',1e-3);

GI = Data.GuildInfo;

ODEData = addIndices(ODEData,GI,Options);

Binit = vertcat(ODEData.Guilds.binit);
cpuTime = zeros(1,ODEData.nYearsFwd);

ResultOptions.File = sprintf('results.txt');

Results = initializeResultStruct(GI,ODEData.nYearsFwd,ODEData.ltspan,Options.Outputs);

for cycle = cycles
    tic
    avgCpuTime = mean(cpuTime(1:cycle-1));
    timeLeftEst = round((end_recovery-cycle+1)*avgCpuTime);
    
    fprintf('Cycle %i/%i starting. Estimated time left %i seconds\n', ...
       cycle, end_recovery, timeLeftEst);
    
    if (cycle > (start_fishing-1) && cycle < (end_fishing+1))
        ODEData.E = ODEData.hmax*gear.selectivity(ODEData.Guilds(GI.iFishGuilds));

%         if strcmp(gearStr,'fyke net')
%             oldFishInds = find([Data.Guilds(GI.iAdultFishGuilds).age] == 4);
%             Data.E(oldFishInds) = Data.E(oldFishInds)*(1-propRelease);        
%         end        
    else
        ODEData.E = zeros(GI.nFishGuilds,1);
    end

    ODEData.year = cycle;

    Xinit = initialValueVector(Binit, GI, Options.Outputs);
    
    % Producer carrying capacity as a function of dissolved detritus biomass
    ODEData.K.values(ODEData.year) = basalProductionCarryingCapacity(Binit(GI.iDOC2), ...
        ODEData.K.mean, Options.isNewVersion);
    try
        [~,X] = ode23(@(t,X)atn_ode(t,X,ODEData,Options), ...
            tspan,Xinit);
    catch ME
        %Data
        %[msgstr, msgid] = lasterr;
        %error(msgstr)
        %ME.message
        ME.identifier
    
    
    end
%     % We can restrict the solution to be non-negative to avoid errors.
%     options = odeset('NonNegative',1:GI.nGuilds);
%     [~,X] = ode23(@(t,X)atn_ode_biomass_catch_gainfish_gain_loss_fast(t,X,Data), ...
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
    
    [Binit, OUT] = reproductionAndAging(Xend, ODEData.Inds, ODEData.Guilds, GI, Options.Outputs);
    Xend(ODEData.Inds.iB) = Binit;
    
    Results = updateResultsStruct(Results,Xend,ODEData.Inds,OUT,X,cycle,ODEData,GI,Options);

    cpuTime(cycle) = toc;
end
%disp(['Simulation finished. The simulation took ' num2str(sum(cpuTime)) ' seconds.'])
%saveResults(Results,ResultOptions,GI);

%CinArray = tehospektri(Results.B);
%cv_values = meanCV(Results.B');

Data_updated = Data; 
Data_updated.path = ResultOptions.Directory;
Data_updated.masses = Results.B; 

%for ss = 1:rows
%   Data_updated.degree(ss).cv_values = cv_values(ss);
%   Data_updated.degree(ss).cindex = CinArray(ss); 

%end

 
%figure(2)
%clf
%for i = 1:12
%    subplot(4,3,i)
%    plot(1:Data.nYearsFwd,Results.B(i,:), 'k--');
    %plot(Results.allbiomasses(i,:), 'k--');
%    hold on;
%end

%{
upperTrophValue = floor(max(Data.TrophLevel)); 
rows = size(Results.allbiomasses,2); 
cv_values = zeros(rows, upperTrophValue); % init. of matrix that includes coefficients of variable for each trophic level (note: levels rounded to integers)

% searching for indexes of each species at a spesific trophic level:

for index1 = 1:upperTrophValue
    trophPos{index1} = find(Data.TrophLevel>=index1 & Data.TrophLevel < (index1 + 1));  %todo: preallocate if needed in the future
end

for index2 = 1:rows
    for index3 = 1:upperTrophValue
        cv_values(index2,index3) = meanCV(Results.allbiomasses(trophPos{index3},index2));
    end
end

figure(3)
subplot(2,2,1)
plot(cv_values(1:10,1))

subplot(2,2,2)
plot(cv_values(1:10,2))

subplot(2,2,3)
plot(cv_values(1:10,3))

subplot(2,2,4)
plot(cv_values(1:10,4))

%power spectrum
figure(200)
subplot(2,2,1)
periodogram(cv_values(:,1))

subplot(2,2,2)
periodogram(cv_values(:,2))

subplot(2,2,3)
periodogram(cv_values(:,3))

subplot(2,2,4)
periodogram(cv_values(:,4))

%}

%for irow = 1:size(Results.allbiomasses,2)
%    fprintf(fid,[repmat('%.6e ',1,GI.nGuilds-1) '%.6e\n'], ...
%        Results.allbiomasses(:,irow)');
%end

 



