% parameters for WebGenerator

%% number of species:
%min_num_species = 15; 
%max_num_species = 35; 
%num_species= 30; % use this if not given as a parameter in
%"generateRandomNetwork.m

%% Number of days of growth
L_year=100;

%% initial connectance
min_connectance = 0.1;
max_connectance = 0.19; 
connectance=0.15;

%% cannibalism for all species
%cannibal_invert=false;

%% fixed seed number for random number generator:
%seed = 7; otherwise this overwrites the one set in output.m

%% massCalc parameters for MassCalc_ATN
masscalc.num_orig_fish=3; %Max number of fish species allowed in original model.  If NaN is used, you choose 60% of species with species with TL>=3 (trophic level)
masscalc.m_fish   =5000;  % mean for fishes
%masscalc.m_fish   =100;  % mean for fishes
masscalc.v_fish   =10; % 100;   % standard deviation for fishes   NOTE: changed to a value of 0 by mijuvest 07062018 (acc. to Fernanda)
masscalc.m_invert =100;   % mean for invertebrates
masscalc.v_invert =10; % 100;   % standard deviation for invertebrates NOTE: changed to a value of 0 by mijuvest 07062018 (acc. to Fernanda)

%% LeslieMatrix
prob_mat.invest=[1,0.9,0.85,0.8]; % allocation to growth for class 1,2 and 3
prob_mat.starta50=3;%Age at which 50% of fish reach maturity BEFORE evolution starts.
leslie.forced=0.5;%How much do you force last life stage to contribute to reproduction? 0 is nothing (they'll stay adults forever), and 1 is everything.

%% LifeHistories
lifehis.agerange=[1,1]; %[4,4]; %[4, 4]; %[1,1]; %[4, 4]; %[4, 4]; %WARNING!!!: only works right now for [4 4] (fix LeslieMatrix). %Range of total number of fish lifestages to add.  You can choose any number within that range. %Jeff said most fish are within 2-6 [2 6] years for age at maturity.
lifehis.growth_exp=3;%Growth exponent, 3 is for isometric growth (Sangun et al. 2007)
lifehis.infsize=0.9;%infsize=W_max./W_inf --> it's the ratio of the size at maturity to asymptotic size. 0.9 was chosen to constrain t_0 to work well with other settings.

%% Life History Switches
lifehis.lstages_maxfish=NaN;%NaN;%Maximum number of fish species to create new lifestages for. NaN gives every fish new lifestages.
lifestages_linked=false;%Are life histories linked via leslie matrix?
lstages_B0ratedR=false;%Start simulation with adults only.
cannibal_invert=false;%Cannibalism for all species
lifehis.cannibal_fish=-Inf;%-Inf=none,Inf=yes & any stage can cannibalize larger stages, -1=cannibalism on strictly smaller stages,0=cannibalism on own stages and smaller stages.% The number for cannibal_fish indicates how much younger conspecifics need to be to be cannibalized.  Of note: -1 means strictly younger, 0 means same lifestage or younger
lifehis.fishpred=2;%Choose how to assign fish predators. 0 means only adults eaten, 1 means all stages are eaten, and 2 reassigns them according to nichevalues
lifehis.splitdiet=true; %false;%Choose how to split fish diet. true=split orignal diet, false=assign new diet based on new niche values
evolv_diet=0;%Fishing evolution induced dietary shifts, so shifts diet to the left or right.  negative numbers make fish eat smaller things, positive numbers make them eat larger (to test whether it's just a matter of messing up the food web). 0 is no diet shift. if diet is already eating smallest node then untransformed.

%% metabolic_scaling
% Allometric scaling exponent (Boit et al. in prep.)
meta_scale.A_fish=0.11;
meta_scale.A_invert=0.15;

%% setup - Intrinsic growth parameter "r" for basal species only
%Original code that Anna sent me set the r of basal within min max range of (0.6,1.2), citing (Boit et al, in prep). Attached methods.doc conflicted with original code, claiming range of (0.6,1.6), citing same source.
%"Good" Perrine code (from Fernanda) has following parameters, which make more sense because at least it's symmetrical.
%Caution: can't use structure here that ends with .mean or .max because attaching those would ruin basic functions.
r_i_mean=0.9;%Original was 1.1
r_i_std=.2;%Original was .18
r_i_min=0.6;%Original was 0.6
r_i_max=1.2;%Original was 1.2

%% setup - Other Dynamic Parameters
K_param=540;%carrying capacity
assim.max_rate=10;
assim.effic_nonplants=.85;%assimilation efficiency of i for j (for fish and inverts)
assim.effic_basal=.45;%assimilation efficiency of i for j (for plants)
f_a = 0.4;% fraction of assimilated carbon used for production of consumers biomass under activity
f_m = 0.1;% fraction of assimilated carbon respired by maintenance of basic bodily functions
q =.2;%.2;% q>0 gives type III response (set to a scalar here) [according to Fernanda Valdovinos, this one parameter makes a huge difference to stability]
%q - biomasses to power q+1, which regulates shape of Holling-curve (h=1+q) Fernanda says h=1.2 is stable for normal webs.

%% func_resp_scaling
%func_resp.pred.prey the functional response of a predator when it eats the listed prey.
%K and Bsd are Half-saturation density of prey (j) when consumed by predator (i)
%c is predator interference for predator (i) consuming prey (j)

%fix my mijuvest 20.6.2018 (doing nothing at the moment; reasoning for this: units should be mug/m3, not mug/l in ATN by Tommi)
scaling = 1; 
func_resp.invert.K_invert    =1.5*scaling; % low half saturation density
func_resp.invert.c_dist      =0.2;% competition  coefficient is exponential distribution with mu=0.2 (i.e. lambda=5)
func_resp.invert.c_max       =0.5;% competition  coefficient is limited to 0.5

func_resp.fish.fish_K        =15*scaling;%if a fish (i) eats another fish (j)  
func_resp.fish.fish_c        =3*10^-4;%

func_resp.fish.omni_K        =50*scaling; %if the invertebrate prey j is omnivore
func_resp.fish.omni_c        =10^-4;% %if the invertebrate prey j is omnivore

func_resp.fish.herb.smallZ_K =150*scaling;%if the invertebrate prey j mostly herbivore is 50 times smaller than the fish predator  
func_resp.fish.herb.smallZ_c =1;%

func_resp.fish.herb.largeZ_K =15*scaling;%if the invertebrate prey j mostly herbivore is not very much smaller than the fish predator
func_resp.fish.herb.largeZ_c =10^-4;%


