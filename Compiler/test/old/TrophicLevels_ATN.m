%--------------------------------------------------------------------------
% Rosalyn Rael
%  Modified Apr 2011 Barbara Bauer, changed metabolic rates of basals
%  to zero (Brose et al. 2006) and rewrote some comments
%  Modified March 2012 Perrine Tonin, added distinction bewteen
%  invertebrates and fishes, stochasticity in the consumer-resource
%  body size constants Z and rewrote some comments
%--------------------------------------------------------------------------
%  Computes Trophic Position
%  Reference: Brose et al. PNAS 2009
%  Uses the following parameters:
%  nichewebsize, nicheweb, basalsp
%--------------------------------------------------------------------------

function [T,T1,T2]= TrophicLevels_ATN(nichewebsize,nicheweb,basalsp)
    %% Shortest Path Trophic Position (T1)
    % Compute shortest path to basal species for each species.
    % Note: the matrix 'nicheweb' is oriented rows eat columns. 
    
    % Set up vector for storing values
    T1=NaN(nichewebsize,1);

    % Find all species with T1=1 -> Basal species (autotrophs)
    T1(basalsp)=1;  % Assign level 1 to basal species.
    ind=basalsp;    % Set up index to basal species

    % Assign other trophic levels.
    for j=2:nichewebsize
        [r,~]=find(nicheweb(:,ind)~=0);%Find all species that eat previous trophic level
        ind = unique(r);%Unique Index of species that consume previous trophic level.
        for i=ind'
            if isnan(T1(i)) % Don't give new values to species that already have trophic levels.
                T1(i)=j;
            end
        end 
    end

    %% Prey Averaged Trophic Position (T2)
    T2 = TL_PreyAveraged(nicheweb);
    
    %% Short Weighted Trophic Position
    % Better estimate of Trophic position than T1 or T2 on their own:
    % Carscallen et al. Estimating trophic position in marine and estuarine food webs (2012)
    T=(T1+T2)/2;

end
