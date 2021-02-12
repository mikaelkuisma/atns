N = 1000;
M = 1+rand(N,1); % starting mass 1-2
fm=0.1;
G = rand(N,1); % Relative goodnes of the fish
% B = Available prey biomass
dt=0.1;
data = zeros(N, 1000);
B = 1000;
B0 = 1000;
w = ones(N,1);
for iter=1:1000
Gtot = sum(G.*w);

dMdt = -fm*M + (G.*w)./Gtot.*M;
w = w - exp(-dMdt).*w*dt;
M = M + dMdt*dt;
data(:, iter) = M;
end
plot(data')