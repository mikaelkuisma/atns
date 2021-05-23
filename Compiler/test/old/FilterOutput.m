function FilterOutput
% filtering obtained results

% Reading already generated webs, incl. biomasses (from ATN model basic
% simulation)
% If results are stable and do not show any "trends" (no shifting in
% averages, etc.), the structures are saved for later use. 

%load testing_seed23_c_scaled.mat outputStructure; 
load testing_seed11_noageclasses_35_species_08092019.mat outputStructure; 
[a,b] = size(outputStructure); % how many webs in total

filtered_outputStructure = repmat(struct('data', []), a, 1); 

%{
checkIfEmpty = true;
s = 1;
while checkIfEmpty
    checkIfEmpty = isempty(outputStructure(s).data)
    if checkIfEmpty
        s = s+1;
        continue; 
    else
        [c,d] = size(outputStructure(s).data.masses);
        break; 
    end
end
%}

succwebs_count = 0;
filtered_count = 0; 

r = 1:20; % "the x points"

for ii = 1:a
   if isempty(outputStructure(ii).data)
       continue; 
   end
   succwebs_count = succwebs_count + 1;
   
   if (~exist('c','var') && ~exist('d','var'))
       [c,d] = size(outputStructure(ii).data.masses);
       fitStats = zeros(c,1);
       pointStats = zeros(c,1);
       %windowStats = zeros(c,2); 
       
   end
   
   %
   % finding indeces for fishes in each data structure:
   %% Below: for age-structured fish guilds: 
   %fCells = {outputStructure(ii).data.Guilds.type};
   %fishIndex = find(strcmp(fCells,'Fish'));
   %consumerIndex = find(strcmp(fCells,'Consumer'));
   %producerIndex = find(strcmp(fCells,'Producer'));
   
   %% 08092019: for fishes without age structure; here fish guilds have been marked as "consumers", so different struct field have been used. 
   %% => slighty different solution for finding indices. 
   fCells = {outputStructure(ii).data.Guilds.name};
   pattern1 = regexptranslate('wildcard', 'Fish*');
   pattern2 = regexptranslate('wildcard', 'Consumer*');
   pattern3 = regexptranslate('wildcard', 'Producer*');
   matches1 = regexp(fCells, pattern1);
   matches2 = regexp(fCells, pattern2);
   matches3 = regexp(fCells, pattern3);
   fishIndex = find(~cellfun(@isempty,matches1));
   consumerIndex = find(~cellfun(@isempty,matches2));
   producerIndex = find(~cellfun(@isempty,matches3));
   
   % checking the linear trends (the curve should be close to zero). Here
   % we use 20 last values of the biomasses for each species
   for jj = 1:c      
       
        % the last 20 values for biomasses for each species at one species
        % at time
        temp = outputStructure(ii).data.masses(jj,(d-19):d);
        
        % checking the linear trends (the curve should be close to zero)
        T = polyfit(r,temp,1);     
        fitStats(jj) = T(1);
        
        % checking the moving average for both odd and even windows sizes
        % odd: 3 points, even: 4 points. The values are used to compute std
        % for the averages
        
        %R_odd = movmean(temp,3);
        %R_even = movmean(temp,4);
        %windowStats(jj,1) = std(R_odd);
        %windowStats(jj,2) = std(R_even);
        
        %CV for the species, mijuvest 8.5.2019:
        pointStats(jj) =  std(temp)/mean(temp); % coefficient of variation, CV   % std(temp/max(temp));    %std(temp); 0.01;
        
        %if (isnan(pointStats(jj)))
        %    pointStats(jj) = 0; 
        %end
            
   end
   
   %standard deviations for curves:
   %fitStd = std(abs(fitStats));
   
   % a new approach by mijuvest 8.5.2019
   % CV for curves:
   fitCV = std(fitStats)/mean(fitStats);
   %fitCurveAve = sum(fitStats)/c;
   
   %a sort of indicator for the fluctuation of the last simulation results:
   % if stds are > 0.005 => neglect the simulation
   %w = find(pointStats > 0.001);  
      
   
   % old version:
%    %if std below threshold => 
%    if (fitStd <= 1 && isempty(w))
%        filtered_count = filtered_count + 1;
%        filtered_outputStructure(filtered_count).data = outputStructure(ii).data; 
%        %[fitStd, ii] 
%    else
%        %[fitStd, ii]
%        %w
%    %    plot(pointStats)
%    %    pause
%    end
   
    % the number of "extincted" fishes in the end of the simulation
    finalMasses = outputStructure(ii).data.masses(fishIndex,end);
    zeroMasses = find(~finalMasses);
    numberOfDead = length(zeroMasses);
    
    % the number of extincted other species:
    finalProdMasses = outputStructure(ii).data.masses(producerIndex,end);
    zeroProdMasses = find(~finalProdMasses);
    numberOfDeadProds = length(zeroProdMasses);
    
    finalConsMasses = outputStructure(ii).data.masses(consumerIndex,end);
    zeroConsMasses = find(~finalConsMasses);
    numberOfDeadCons = length(zeroConsMasses);

   % new version by mijuvest 8.5.2019:
   
   if (fitCV <= 0.02 && mean(pointStats(~isnan(pointStats))) <= 0.02)
       filtered_count = filtered_count + 1;
       filtered_outputStructure(filtered_count).data = outputStructure(ii).data; 
       filtered_outputStructure(filtered_count).data.numberOfDeadSpecies = numberOfDead;
       filtered_outputStructure(filtered_count).data.numberOfDeadCons = numberOfDeadCons;
       filtered_outputStructure(filtered_count).data.numberOfDeadProds = numberOfDeadProds;
   end
   
   
end


% succwebs_count
% filtered_count

%saving successfull webs:
%filtered_outputStructure = repmat(struct('data', []), filtered_count, 1); 
%save('filteredwebs_seed23_c_scaled.mat', 'filtered_outputStructure');
save('filteredwebs_testing_seed11_noageclasses_35_species_22092019.mat', 'filtered_outputStructure');

%plotting histogram of numbef of dead fishes:
histdata = zeros(filtered_count,1);

% number of other dead species:
histdata2 = zeros(filtered_count,1);
histdata3 = zeros(filtered_count,1);

for ss = 1:filtered_count
    histdata(ss) = filtered_outputStructure(ss).data.numberOfDeadSpecies;
    histdata2(ss) = filtered_outputStructure(ss).data.numberOfDeadCons;
    histdata3(ss) = filtered_outputStructure(ss).data.numberOfDeadProds;
end

subplot(3,1,1)
histogram(histdata, 'Normalization','probability')    
xlabel('number of dead age classes for fishes');  
titlestr = ['Number of filtered webs (out of ', num2str(succwebs_count), ' webs): ', num2str(filtered_count)]; 
title(titlestr);

subplot(3,1,2)
histogram(histdata2, 'Normalization','probability')    
xlabel('number of dead consumers');   

subplot(3,1,3)
histogram(histdata3, 'Normalization','probability')    
xlabel('number of dead producers');   











