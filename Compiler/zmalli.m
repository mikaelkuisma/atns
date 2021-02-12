% s. 30, marjomäki väitöskirja taulu 2
% 164 taulukon otsikosta week 1-automn aikavälin pituus päivinä
t=linspace(0,164,1000);

clf
hold on
for i=1:100
% All-data daily Z week 1-autumn
Z = exp(-4.74) + sqrt(exp(-8.49))*randn(1);
 % Elossa olevat toukat päivän funktiona
plot(t,exp(-Z*t));
hold on
end
% Sama taulukko, kokonais Z, menee yllä olevan päiväkäyrän kanssa yhteen
plot(164, exp(-3.9),'or');

% Tehdään log-normal jakauma, jonka keskiarvo on exp(-3.9) ja hajonta 2.35.
N = 5000;
sigma = 2.35/10; % sd väitöskirjasta
kohina = randn(N,1)*sigma; % Normaalijakauma jonka keskihajonta on sd.



% lognormal jakauma jonka keskiarvo on exp(-3.9) ja keskihajonta on mikä on
lognormal_jakauma = exp(-3.9-1/2*sigma^2)*exp(kohina);
mean(lognormal_jakauma)
%hist(lognormal_jakauma,16000);
plot(164, exp(-3.9-1/2*sigma^2)*exp(kohina),'xb');
