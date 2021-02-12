%Lfunction individual_genetics
carrying_capacity = 75;
Nfish = 1000;
maturation_threshold = 0.7;
Ngenes = 10;
emptydata = struct('ages', {}, ...
              'maturity', {}, ...
              'length', {}, ...
              'vbf_Linf', {}, ...
              'vbf_L0', {}, ... 
              'vbf_K', {}, ... 
              'growth_time', {}, ... 
              'isfemale', {}, ... 
              'genes', {});
data=emptydata;          
for i=1:Nfish
    fish.ages = randi(7);
    fish.maturity = 1;
    fish.length = rand();
    fish.vbf_Linf = 20+20*rand();
    fish.vbf_L0 = 1;
    fish.vbf_K = 1;
    fish.growth_time = 0;
    fish.isfemale = randi(2)-1;
    fish.genes = randi(2, Ngenes)-1;
    data(i) = fish;
end

Nyears = 1000;
%  sizeTOweight=function(size){
%    wg=(0.006525746)*size^2.943/1000 #omasta Puulamuikkudatasta laskettu regressio lm(lnweight(g)~lnlength(cm) 
%  }

for y=1:Nyears
    Nfish = numel(data);    
    for i=1:Nfish
        data(i).ages = data(i).ages + 1;
    end
    mortality = 0.01; % TODO age dependent
    data = data(rand(Nfish, 1) > mortality);
    Nfish = numel(data);    

    fish_length = [ data.length ];
    fish_weight=(0.006525746)*fish_length.^2.943/1000;
    total_biomass = sum(fish_weight);
    z = 15*(1-1/0.85*total_biomass/carrying_capacity);
    growth_time = exp(z)/(1+exp(z));
    
    % Growth
    vbf_Linf = [ data.vbf_Linf ];
    vbf_L0 = [ data.vbf_L0 ];
    vbf_K = [ data.vbf_K ];
    for i=1:Nfish
        data(i).growth_time = data(i).growth_time + growth_time;
        data(i).length = data(i).vbf_Linf -(data(i).vbf_Linf-data(i).vbf_L0)*exp(-data(i).vbf_K*data(i).growth_time);
    end
    
    for i=1:Nfish
        data(i).maturity = data(i).maturity || (data(i).length > maturation_threshold*data(i).vbf_Linf && data(i).age>1);
    end
    
    ismature = [ data.maturity ];
    matures = data(ismature);
    isfemale = [ matures.isfemale ];
    males = data(~isfemale);
    females = data(~~isfemale);
    numel(males)
    numel(females)
    partners = males(randi(numel(males), 1, numel(females)));
    for fi = 1:numel(females)
        female = females(fi);
        male = partners(fi);
        Njuv = 2; % TODO
        
    
        offspring = emptydata;
        for j = 1:Njuv
            fish.genes = zeros(2, Ngenes);
            for g=1:Ngenes
               fish.genes(1,g) = male.genes(randi(2), g);
               fish.genes(2,g) = female.genes(randi(2), g);
            end
            fish.ages = 0;
            fish.length = 1;
            fish.vbf_Linf = 40;
            fish.vbf_L0 = 1;
            fish.vbf_K = 1;
            fish.growth_time = 0;
            fish.isfemale = randi(2)-1;
            offspring(end+1) = fish;
        end
    end
    
    data = [ data offspring ];
    plot( [data.length, data.ages ]);
    pause
    L(y) = mean( [ data.length ]);        
    N(y) = Nfish;
end
plot(N);
hold on
plot(L)