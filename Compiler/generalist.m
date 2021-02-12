function generalist
N = 6;
global intra
global inter
global Bprod
global K
global s
global B0
global e
global igr
global y
global q
global Btr1
global mbrtr1
global fa;
global fm;
global omega
conns = linspace(0,1,21);
conns=conns(2:21);
intra = 1.1;
inter = 1;
fa = 0.4;
fm = 0.1;
K = 1;
y = 4;
q = 1.2;
B0 = 0.25;
e=0.4;
iterations = 10000/20;
connections = 20;
data = zeros(2*N,50, 20, iterations);

for iter = 1:1000
igr = lognormal(N, 1.0, 0.1);
Bprodinit = lognormal(N, 1/N, 0.4/N);
Btr1init = lognormal(N, 0.5/N, 0.5/N);
mbrtr1 = lognormal(N, 0.25, 0.2);
s = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2];
    for connid = 1:connections
        
        conn = conns(connid);
omega = rand(N) < conn;
while ~all(sum(omega,1)) || ~all(sum(omega,2))
   omega = rand(N) < conn;
end
omega = omega ./sum(omega, 2);

dt=1;
Bprod = Bprodinit;
Btr1 = Btr1init;

for i=1:iterations
    data(:,iter, connid, i) = [ Bprod Btr1 ];
    [dBproddt, dBtr1dt] = gradient;
    Bprod = Bprod + dBproddt*dt;
    Btr1 =  Btr1 +  dBtr1dt*dt;
end
    end

% data(guild_index, iterations, conn_id, time)
hold off
time_std = std(data(:,1:iter,:,iterations/2:end),[],4);
%variation_in_time = squeeze(mean(mean( var(data(:,1:iter,:,iterations/2:end),[],4), 2),1));
figure(1);
clf
for id = 1:connections
    subplot(5,4,id);
    th = time_std(:,:, id);
    histogram(th(:), linspace(0,0.50,100));
    set(gca,'YScale','log')
    %hist(th(:));
end
%plot(conns, variation_in_time)
pause(0.1);
figure(2);
clf
for id = 1:connections
    subplot(5,4,id);
    for k=1:12
    plot(squeeze(data(k,iter,id,:))','k');
    hold on
    end
    set(gca,'YScale','log')
    ylim([0.01 1]);    
    if 0
    %mu = mean(data(:,1:iter,id, :),2);
    %dev = std(data(:,1:iter,id, :), [],2) / 10;
    mu = squeeze(mu);
    dev = squeeze(dev);
    plot(mu','r');
    hold on
    plot((mu+dev)','k--');
    plot((mu-dev)','k--');
    end
    
    title(num2str(conns(id)));
end    
pause(0.1);
end

function [dBproddt, dBtr1dt] = gradient
global intra
global inter
global Bprod
global K
global s
global igr
global y
global q
global fa
global B0
global Btr1
global fm
global mbrtr1
global omega
global e
Bprodsum = sum(Bprod);
g = 1 - (inter*Bprodsum-Bprod*(inter-intra))/K;
dBproddt = (1-s).*igr.*g.*Bprod;

dBtr1dt = -fm*mbrtr1.*Btr1;
num = omega.*repmat(Bprod, 6,1);
Beff = repmat(sum(num,2), 1,6);
F = num ./ (B0.^q + Beff);

feeding_rates = fa*mbrtr1.*F.*repmat(Bprod', 1,6);
losses = sum(feeding_rates, 1)/e;
gains = sum(feeding_rates, 2)';
dBtr1dt =dBtr1dt +gains;
dBproddt =dBproddt +losses;

%parameter tr1Bodymass = 10;
%parameter tr1MuMbr = 0.1*tr1Bodymass^(1/9);
%parameter tr1mbr = @lognormal(N, tr1MuMbr, tr1MuMbr/5);
%parameter fm = 0.1;
%dynamic Btr1 = @lognormal(N, 0.5, 0.2);
%parameter generalistness = @rangenobnd(0,1, N);
%parameter omega = [ @rand(N) < a*generalistness+b, 
%                    @rand(N) < a*generalistness+b,
%                    @rand(N) < a*generalistness+b,
%                    @rand(N) < a*generalistness+b,
%                    @rand(N) < a*generalistness+b,
%                    @rand(N) < a*generalistness+b ];
%
%omega = @rand(N,N)
%.Btr1 = - fm * tr1mbr*Btr1;

function value = lognormal(N, m, s)
  v = s^2;
  mu = log((m^2)/sqrt(v+m^2));
  sigma = sqrt(log(v/(m^2)+1));
  value = lognrnd(mu, sigma, 1, N);