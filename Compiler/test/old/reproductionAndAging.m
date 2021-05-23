function [Bnew, OUT] = reproductionAndAging(X, Inds, Guilds, GuildInfo, Outputs)

OUT.SSB = 0;
OUT.JB = 0;
Bnew(GuildInfo.iDetritusGuilds,:) = X(GuildInfo.iDetritusGuilds);
Bnew(GuildInfo.iProducerGuilds,:) = X(GuildInfo.iProducerGuilds);
Bnew(GuildInfo.iConsumerGuilds,:) = X(GuildInfo.iConsumerGuilds);

gfl = {Guilds(GuildInfo.iFishGuilds).label}; 
gal = {Guilds(GuildInfo.iAdultFishGuilds).label};
gjl = {Guilds(GuildInfo.iJuvenileFishGuilds).label};
gll = {Guilds(GuildInfo.iLarvaeFishGuilds).label};
S.subs = {1,1:3}; S.type = '()';
fslabels = cellfun(@(x)subsref(x,S),gfl,'uniformoutput',false);
afslabels = cellfun(@(x)subsref(x,S),gal,'uniformoutput',false);
jfslabels = cellfun(@(x)subsref(x,S),gjl,'uniformoutput',false);

for k = 1:GuildInfo.nLarvaeFishGuilds
    
    IL = GuildInfo.iLarvaeFishGuilds(k);
    gl = Guilds(IL).label;
    gl = gl(1:3);

    if strcmp(gl,'Tro')
        
        IATro = GuildInfo.iAdultFishGuilds(strcmp(afslabels,'Tro'));
        IJTro = GuildInfo.iJuvenileFishGuilds(strcmp(jfslabels,'Tro'));
        spawnerBM = sum(X(IATro).*vertcat(Guilds(IATro).Pmat));
        juvenileBM = X(IJTro);
        alpha = 1.2850e-02;
        beta = 5.7059e-05;
        newbornBM = alpha*spawnerBM/(1+beta*spawnerBM) + Guilds(IL).hatchery;
        %sigma = .5;
        %newbornBM = lognrnd(log(newbornBM)-.5*sigma,sigma);
        
        if Outputs.SSB
            OUT.SSB(k) = spawnerBM;
        end
        
        if Outputs.JB
            OUT.JB(k) = juvenileBM;
        end
        
    else
        
        newbornBM = 0;
        if ~isempty(Inds.iGF)
            newbornBM = sum(X(Inds.iGF(strcmpi(fslabels,gl))));
        end

        if Outputs.SSB
            IAFish = GuildInfo.iAdultFishGuilds(strcmp(afslabels,gl));
            spawnerBM = sum(X(IAFish).*vertcat(Guilds(IAFish).Pmat));
            OUT.SSB(k) = spawnerBM;
        end
        
        if Outputs.JB
            IJFish = GuildInfo.iJuvenileFishGuilds(strcmp(jfslabels,gl));
            juvenileBM = X(IJFish);
            OUT.JB(k) = juvenileBM;
        end
        
    end
    
    Bnew(IL,:) = newbornBM + Guilds(IL).hatchery;
    
end

for k = 1:GuildInfo.nJuvenileFishGuilds

    IJ = GuildInfo.iJuvenileFishGuilds(k);
    gl = Guilds(IJ).label;
    gl = gl(1:3);
    IL = GuildInfo.iLarvaeFishGuilds(strcmpi(gll,[gl '0']));
    
    Bnew(IJ,:) = X(IL) + Guilds(IJ).hatchery;
    
end

for k = 1:GuildInfo.nAdultFishGuilds        % TODO: Optimize for speed
    
    IA = GuildInfo.iAdultFishGuilds(k);
    gl = Guilds(IA).label;
    ga = Guilds(IA).age;
%     ga = str2double(gl(4));
%     gl = gl(1:3);
    
    iJA = [GuildInfo.iJuvenileFishGuilds GuildInfo.iAdultFishGuilds];
    gal = {Guilds(iJA).label};
    for j = 1:length(gal)
        if ga < 4 && strcmpi(gal{j}(1:3),gl(1:3)) && gal{j}(4) == num2str(ga-1)
            IJA = iJA(j);
            Bnew(IA,:) = X(IJA) + Guilds(IA).hatchery;
            break;
        elseif ga == 4 && strcmpi(gal{j}(1:3),gl(1:3)) && gal{j}(4) == num2str(ga-1)
            IJA = iJA(j);
            Bnew(IA,:) = X(IA) + X(IJA) + Guilds(IA).hatchery;
            break;
        end
        
    end
end