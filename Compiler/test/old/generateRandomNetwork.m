function [Data] = generateRandomNetwork(num_species)
% A function that produces a niche model food web and stores them in
% a structure. Done on the top of the code by Stephanie B. et al. 
% mvesterinen Feb 19 2018


% loading previous Data structure (presuming this code is run from subfolder): 
%load('..\1_LakeConstance.mat'); 
%load('1_LakeConstance.mat'); 
%load ('Data\1_LakeConstance.mat');

% adding a new field
%Data.TrophLevel_average= []; 
%Data.TrophLevel_preyaveraged = []; 

%Datatemp = Data;
%r = full(Data.adjacencyMatrix)

% the parameter space for the generator:
WebParams;

% ensuring repeatable simulations
%rng(seed); 

%initialization of the struct:
%webs = struct('web', repmat({zeros(num_species)}, conn_length, 1), 'connectance', min_connectance); 

%check_Eating = true; %activate this and the loop below if lifestructure present

%while check_Eating


[web] = NicheModel_ATN(cannibal_invert,num_species,connectance);
nichewebsize = length(web.nicheweb);%Steph: Find number of species (not sure why, already have S_0)
basal_ls=sum(web.nicheweb,2)==0;
basal_species=find(basal_ls);       %List the autotrophs (So whatever doesn't have prey)  Hidden assumption - can't assign negative prey values (but why would you?)

[web.TrophLevel,web.T1,web.T2]= TrophicLevels_ATN(nichewebsize,web.nicheweb,basal_species);
[web.Z,web.Mvec,web.isfish]= MassCalc_ATN(masscalc,nichewebsize,web.nicheweb,basal_species,web.TrophLevel);

%%%LIFE HISTORY
[nicheweb_new,Mass,orig.nodes,species,N_stages,is_split,aging_table,fecund_table,extended_n,clumped_web,Anna_stuff]= LifeHistories_ATN(lifehis,leslie,web,nichewebsize,connectance);

%Update all the output to reflect new web
nichewebsize = length(nicheweb_new);

%extended_web=nicheweb_new;%Save backup of extended web before dietary shift
isfish=repelem(web.isfish,N_stages);
   
%     % checking if there happens cyclic eating among new fishes:
%     if CyclicEating(nicheweb_new, [])
%         continue; 
%     else
%         % if no cyclic eating, setting flag as false
%         check_Eating = false;
%     end
           
%     % checking if there are something in common in the diets of each fish
%     % species:   
%     if CheckFishDiet(nicheweb_new,isfish)
%         %breaking the loop is all is ok:
%         check_Eating = false;
%     else
%         %continue the execution of the loop by overwriting the previous flag value
%         check_Eating = true; 
%     end
    
    
%end
    

%meta_N_stages=repelem(N_stages,N_stages);
lifestage=[];
for i=1:num_species
    lifestage=[lifestage 1:N_stages(i)];            % TODO: if tons of runs, fix this (mvesteri 6.3.2018)
end

%Mvec=Mass;
basal_ls=basal_ls(species); %Update basal species
basal_species=find(basal_ls);

    
    
%%  SET DYNAMICS PARAMETERS

[TrophLevel,T1,T2]= TrophicLevels_ATN(nichewebsize,nicheweb_new,basal_species);%Recalculate trophic levels for new nicheweb

%[nicheweb_new] = CreateFishDiet(0.9, 0.1, nicheweb_new, isfish, TrophLevel);


[meta,Z]=metabolic_scaling_ATN(meta_scale,basal_species,isfish,Mass,web,species);

%Intrinsic growth parameter "r" for basal species only
%-----------------------------------------------------
int_growth = zeros(nichewebsize,1);
int_growth(basal_species)=r_i_mean+r_i_std*randn(length(basal_species),1);
while max((basal_ls & int_growth<r_i_min) | int_growth>r_i_max)>0%Changed to while loop so that the distribution isn't truncated and sharp at edges (original compressed the tails into little lumps at either side of the range.)
    to_replace=((basal_ls & int_growth<r_i_min) | int_growth>r_i_max);
    int_growth(to_replace)=r_i_mean+r_i_std*randn(sum(to_replace),1);
end

%K = ones(nichewebsize,1) .*K_param;
%max_assim=assim.max_rate*ones(nichewebsize);% max rate i assimilates j per unit metabolic rate of i

effic=assim.effic_nonplants*ones(nichewebsize);%assimilation efficiency of i for j
effic(:,basal_species) = assim.effic_basal;

[Bsd, c]=func_resp_scaling_ATN(func_resp,nicheweb_new,nichewebsize,isfish,Mass,basal_species);

%% initial Biomass
%1) Random uniform distribution in interval (0.01,10)
B_orig = (999*rand(nichewebsize,1)+1)*.01;  %x1000 larger values used below for binit

if lstages_B0ratedR==true
    B_orig=B_orig.*orig.nodes';%Start with adults only.
elseif lstages_B0ratedR~=false
    clear B_orig;%Make sure there's an error if you misspell setting
end

%% Final "Data" structure initialization:

Data.adjacencyMatrix = [];
Data.B0 = [];
Data.d = [];
Data.y = [];
Data.q = [];
Data.e = [];

Data.adjacencyMatrix(1:(nichewebsize+2), 1) = 0;    %first column: only zeroes
Data.adjacencyMatrix(1:(nichewebsize+2), 2) = 0;    %2nd column
Data.adjacencyMatrix(1,3:(nichewebsize+2)) = 0;     %1st row 
Data.adjacencyMatrix(2,3:(nichewebsize+2)) = 0;     %2nd row
Data.adjacencyMatrix(3:(nichewebsize+2), 3:(nichewebsize+2)) = nicheweb_new;  % other values

%% "Data" structure update: (note: sizes change here)

% the orig version, commented out 26.08.2019
% Data.B0(3:(nichewebsize+2), 3:(nichewebsize+2)) = Bsd*1000;  
% Data.d(3:(nichewebsize+2), 3:(nichewebsize+2)) = c; %c/1000;    %[c] should be m3/microgC in ATN. Previously liters/microgC
% Data.y(3:(nichewebsize+2), 3:(nichewebsize+2)) = assim.max_rate; 
% Data.q(3:(nichewebsize+2), 3:(nichewebsize+2)) = q+1; 
% Data.e(3:(nichewebsize+2), 3:(nichewebsize+2)) = effic; 

Data.B0(3:(nichewebsize+2), 3:(nichewebsize+2)) = 0;
Data.d(3:(nichewebsize+2), 3:(nichewebsize+2)) = 0; %c/1000;    %[c] should be m3/microgC in ATN. Previously liters/microgC
Data.y(3:(nichewebsize+2), 3:(nichewebsize+2)) = 0; 
Data.q(3:(nichewebsize+2), 3:(nichewebsize+2)) = 0; 
Data.e(3:(nichewebsize+2), 3:(nichewebsize+2)) = 0; 

Data.K.mean = K_param*1000; % Must be mug C / m3, not mug C / l as in Stephanie's original version mijuvest 25.7.2018 
% Data.nGrowthDays = L_year; 

% Here we construct the sparse matrix presentation for the data: 
for jx = 3:(nichewebsize+2)
    for hx = 3:(nichewebsize+2)
        if Data.adjacencyMatrix(jx,hx) 
            Data.B0(jx,hx) = Bsd(jx-2,hx-2)*1000;  
            Data.d(jx,hx) = c(jx-2,hx-2); %c/1000;    %[c] should be m3/microgC in ATN. Previously liters/microgC
            Data.y(jx,hx) = assim.max_rate;
            Data.q(jx,hx) = q+1; 
            Data.e(jx,hx) = effic(jx-2,hx-2); 
        end
    end
end

% sparse version: 
%Data.B0 = sparse(Data.B0);  this done in the end because fishes are set as
%consumers there. 
Data.d = sparse(Data.d);
Data.y = sparse(Data.y);
Data.q = sparse(Data.q);
Data.e = sparse(Data.e);
            

%% structure initialization for Data.Guilds:

% Detritus, from original Lake C. Dataset:
Data.Guilds(1).label = 'DOC1'; 
Data.Guilds(2).label = 'DOC2';
Data.Guilds(1).name = 'Pool of undissolved organic carbon';
Data.Guilds(2).name = 'Pool of dissolved organic carbon';
Data.Guilds(1).type = 'Detritus';
Data.Guilds(2).type = 'Detritus';
Data.Guilds(1).binit = 138848.213679604; 
Data.Guilds(2).binit = 1000000; 
Data.Guilds(1).diss_rate = 0.1;
%Data.Guilds(2).diss_rate = 0.1; 

%resetting the rest:
maxval = nichewebsize+2; 

for jj = 3: maxval
    Data.Guilds(jj).label = '';
    Data.Guilds(jj).name ='';
    Data.Guilds(jj).type = '';
    Data.Guilds(jj).igr = 0; 
    Data.Guilds(jj).mbr = 0;
    Data.Guilds(jj).binit = 0; 
    Data.Guilds(jj).avgl = 0;
    Data.Guilds(jj).lw_a = 0; 
    Data.Guilds(jj).lw_b = 0;  
    Data.Guilds(jj).age = 0; 
    Data.Guilds(jj).s = 0; 
    Data.Guilds(jj).c = 0; 
    Data.Guilds(jj).catchable = 0;
%     Data.Guilds(jj).ax = 0;
    Data.Guilds(jj).f_a = 0;
%     Data.Guilds(jj).bx = 0;
    Data.Guilds(jj).f_m = 0;
end


    
%%

% creating a new "web" structure that stores all important Data of the
% nicheweb_new, including rng values:
 
indx0 = 3; % general running index for all species

indx1 = 0;  % running index for "consumers" 
str1 = 'Consumer#';

indx2 = 0;  % running index for "producers" 
str2 = 'Producer#';

indx3 = 1; % running index for fishes
str3 = 'Fish#'; 
str4 = 'yr'; 

% structure initialization for Data.Guilds:

Data.Guilds(1).diss_rate = 0.1;
Data.Guilds(2).diss_rate = 0.1; 

Data.TrophLevel(1).average = 0; 
Data.TrophLevel(2).average = 0; 
Data.TrophLevel(1).preyaveraged = 0; 
Data.TrophLevel(2).preyaveraged = 0; 
Data.TrophLevel(1).shortestpath = 0; 
Data.TrophLevel(2).shortestpath = 0; 


for ii = 3:maxval
    Data.Guilds(ii).igr  = int_growth(ii-2); % int_growth(ii);
    Data.Guilds(ii).label = strcat('spe', num2str(indx0)); % TODO: fix this
    Data.Guilds(ii).mbr = meta(ii-2); 
    Data.Guilds(ii).binit = B_orig(ii-2)*1000;  % Check the units 
    Data.Guilds(ii).diss_rate = 0; 
    Data.Guilds(ii).age = lifestage(ii-2) - 1; % TODO: check the difference between ATN values and this
    %Data.Guilds(ii).age = 0; % reset everything mijuvest 05.09.2018
    Data.Guilds(ii).hatchery = 0;
    Data.Guilds(ii).invest = 0; 
    %Data.Guilds(ii).avgl = 0;
    %Data.Guilds(ii).lw_a = 0; 
    %Data.Guilds(ii).lw_b = 0;  
    %Data.Guilds(ii).igr = 0; 
    %Data.Guilds(ii).mbr = 0;
    %Data.Guilds(ii).binit = 0;  
    %Data.Guilds(ii).catchable = 0; 
    %Data.Guilds(ii).ax = 0; 
    %Data.Guilds(ii).bx = 0; 
    Data.TrophLevel(ii).average = TrophLevel(ii-2); 
    Data.TrophLevel(ii).preyaveraged = T2(ii-2); 
    Data.TrophLevel(ii).shortestpath = T1(ii-2); 
    
    
    if isfish(ii-2) 
            fishesFixedAge = 2; %starting and the fixed age of fishes. Just some non-zero number if no age structure present. Added 30.4.2019. 
            Data.Guilds(ii).age = fishesFixedAge; % added 30.4.2019. Resets the previous value. 
            %Data.Guilds(ii).binit = Data.Guilds(ii).binit;
            Data.Guilds(ii).avgl = GetLengthFromMass(Mass(ii-2)); %GetLengthFromMass(web.Mvec(ii-2)); % note: this uses lw_a and lw_b values below but are fixed in the function (not incl. as a parameter) %%<-Mass changed to Mvec, 2.5.2019
            Data.Guilds(ii).lw_a = 0.0105;
            Data.Guilds(ii).lw_b = 3.11; 
            Data.Guilds(ii).type = 'Fish';
            %Data.Guilds(ii).hatchery = 0;  
            Data.Guilds(ii).name = strcat(str3, num2str(indx3), ', ', num2str(Data.Guilds(ii).age), str4); 
            Data.Guilds(ii).label = ['F' num2str(indx3) 'A' num2str(Data.Guilds(ii).age)];
            Data.Guilds(ii).Pmat = proba_mature(0,Data.Guilds(ii).age);
            
            % index update for fish:
            if (rem(Data.Guilds(ii).age, fishesFixedAge) == 0 && Data.Guilds(ii).age > 0)        %change fishesFixedAge -> 3 if age classes are activated. 
                indx3 = indx3 + 1; 
            end
            
    end
    
    % other "Data.Guilds.type" definitions:
    
    if (TrophLevel(ii-2)>1 && ~isfish(ii-2))
        indx1 = indx1 + 1; 
        Data.Guilds(ii).type = 'Consumer'; 
        Data.Guilds(ii).name = strcat(str1, num2str(indx1));
        indstr = ['0' num2str(indx1)];
        indstr = indstr(end-1:end);
        Data.Guilds(ii).label = ['C' indstr];        
        
    end
    
   
    if TrophLevel(ii-2) == 1
        indx2 = indx2 + 1; 
        Data.Guilds(ii).name = strcat(str2,num2str(indx2));
        Data.Guilds(ii).type = 'Producer';
        indstr = ['0' num2str(indx2)];
        indstr = indstr(end-1:end);
        Data.Guilds(ii).label = ['P' indstr];
    end
    
    
    Data.Guilds(ii).catchable = 0; 
    % if a fish and old enough:
    if (isfish(ii-2) && (Data.Guilds(ii).age > 1)) 
        Data.Guilds(ii).catchable = 1; 
    end
    
    if (isfish(ii-2) && Data.Guilds(ii).age ==1)
        Data.Guilds(ii).invest = 0.1; 
    elseif (isfish(ii-2) && Data.Guilds(ii).age ==2)
        Data.Guilds(ii).invest = 0.15; 
    elseif (isfish(ii-2) && Data.Guilds(ii).age >=3)
        Data.Guilds(ii).invest = 0.2; 
    end
        
        
    if TrophLevel(ii-2) == 1
        Data.Guilds(ii).c = 1; 
        Data.Guilds(ii).s = 0.2; 
    else
        Data.Guilds(ii).c = 0; 
        Data.Guilds(ii).s = 0; 
    end
    
    % ax
    if (TrophLevel(ii-2) > 0 && ~strcmp(Data.Guilds(ii).type,'Producer'))
%         Data.Guilds(ii).ax = f_a; 
        Data.Guilds(ii).f_a = f_a; 
%         Data.Guilds(ii).bx = f_m; 
        Data.Guilds(ii).f_m = f_m;         
    end
    
    indx0 = indx0 + 1; % update for "label"
    
end

% the basic version of Data saved
%save('Data\testi_seed10_XX01092019.mat','Data')

%Let's reset all fields associated with the type "fish" (if no age structure present):
types = {Data.Guilds.type};
indexx = find(strcmp(types,'Fish'));
for ix = indexx
    Data.Guilds(ix).type = 'Consumer';
    Data.Guilds(ix).Pmat = {};
    Data.Guilds(ix).avgl = {};
    %Data.Guilds(ix).catchable = 0; 
    Data.Guilds(ix).avgl = {}; 
    Data.Guilds(ix).lw_a = {}; 
    Data.Guilds(ix).lw_b = {}; 
    Data.Guilds(ix).hatchery = {};
    Data.Guilds(ix).igr = {};
    Data.Guilds(ix).invest = {};
    Data.Guilds(ix).Pmat = {}; 
    Data.Guilds(ix).c = {}; 
    Data.Guilds(ix).diss_rate = {}; 
    Data.Guilds(ix).mbr = meta(ix-2); 
    Data.Guilds(ix).age = {}; 
    %indexx_b = find(Data.B0(ix,:));
    %Data.B0(ix, indexx_b) = 50000;
    
end
%save('Data\testi_seed10_XXx01092019.mat','Data')

Data.B0 = sparse(Data.B0);  


% % from graph math (ref: Barabas - network theory) for directed networks:
% Data.degree= [];
% Data.degree(1).in = 0; 
% Data.degree(1).out = 0; 
% Data.degree(2).in = 0; 
% Data.degree(2).out = 0; 
% % clustering coeffs:
% Data.degree(1).ccin = 0;
% Data.degree(1).ccout = 0; 
% Data.degree(2).ccin = 0; 
% Data.degree(2).ccout = 0; 
% sumin = 0; 
% sumout = 0; 
% 
% 
% for kk = 3:maxval
%     Data.degree(kk).in = sum(Data.adjacencyMatrix(:,kk)); 
%     index_in = find(Data.adjacencyMatrix(:,kk)) ; % findind non-zero elements = incoming edges
%     Data.degree(kk).ccin = clusterCoeff(Data.adjacencyMatrix, index_in);
%     sumin = sumin + Data.degree(kk).in; 
%     
%     Data.degree(kk).out =sum(Data.adjacencyMatrix(kk,:));
%     index_out = find(Data.adjacencyMatrix(kk,:)) ; % findind non-zero elements = outgoing edges
%     Data.degree(kk).ccout = clusterCoeff(Data.adjacencyMatrix, index_out);
%     sumout = sumout + Data.degree(kk).out; 
% end
% 
% Data.degree(1).averagein = 1/maxval*sumin; 
% Data.degree(1).averageout = 1/maxval*sumout; 
% 

%if degree distribution as a bar plot is needed:


% xin = sum(Data.adjacencyMatrix,1);
% xout = sum(Data.adjacencyMatrix,2);
% 
% [xin_hist,loc1] = hist(xin,0:maxval);
% [xout_hist, loc2] = hist(xout,0:maxval);
% 
% xin_perc = xin_hist/sum(xin_hist); 
% xout_perc = xout_hist/sum(xout_hist);
% 
% figure(100); 
% subplot(2,1,1);
% bar(loc1, xin_perc);
% xticks([1:ceil(max(loc1))]);
% 
% subplot(2,1,2);
% bar(loc2, xout_perc);
% xticks([1:ceil(max(loc2))]);



%saving as a new "Data" struct to the folder one above the current one:
%curr_folder = cd; 
%upper_folder = fullfile(curr_folder, '..'); 
%save(fullfile(upper_folder, '1_LakeConstance_updated_nicheweb.mat'), 'Data'); 

%save('1_LakeConstance_updated_nicheweb.mat', 'Data'); 


