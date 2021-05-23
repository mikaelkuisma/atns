function cv = meanCV(bioMassArray)
% this function calculates the coefficient of variation for the given array
% Called in "NicheModeller.m"
cv = std(bioMassArray)./mean(bioMassArray); 
 