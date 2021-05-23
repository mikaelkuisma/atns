function v = GetLengthFromMass(mass)
% a script that returns the length of the fish species
% Based on (what?)

%mass = lw_a*length**(lw_b)
mass = mass/1e3; 
%mass = mass; 
%Units: [mass] = g, [length] = cm, [lw_a] = g/cm3
lw_a = 0.0105; 
lw_b = 3.11; 
v = (mass/lw_a)^(1/lw_b); 

