function iEatsj = CyclicEating(cmatrix, indeces)
% checking if there is a species i that eatc species j that eats also i...
% mijuvest 19.6.2018
% a supersmall test change 9.4.2019

iEatsj = false; 


switch nargin
    case 1              % this part called in NicheModel_ATN
    [a,b] = size(cmatrix);
    indeces = 1:b;
    case 2              % this part after generating fishes in generateRandomNetwork.m
    a = length(indeces);
end
        

for ii = 1:a
    indx = find(cmatrix(ii,indeces));
    if isempty(indx)
        continue;
    else
        for jj = 1:length(indx)
            if (cmatrix(ii,indx(jj)) && cmatrix(indx(jj),ii))
                iEatsj = true;
            end
        end
    end
end



