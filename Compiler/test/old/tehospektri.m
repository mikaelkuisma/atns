function [CinArray] = tehospektri(timeseries) 

close all; 
%% R-koodi:
%{
t =seq(0,200,by=0.1)
x =cos(2*pi*t/16) + 0.75*sin(2*pi*t/5)
par(mfrow = c(2,1))
plot(t,x,'l')
spectrum(x,)
%}

%{
fs = 10; % sampling freq
t = 0:1/fs:200; % time vector
f1 = 2/16;
f2 = 2/5; 

x =cos(2*pi*t/16) + 0.75*sin(2*pi*t/5); 
figure(1)
subplot(2,1,1)
plot(t,x)
p= nextpow2(t(end));   % the closest power of two
nfft = 2^p; % creating number of points for fft (fastest when doing this)

X = fft(x,nfft); 
% fft symmetric, throw away second half
X = X(1:nfft/2);

XX = abs(X);  % the magnitude of X

%Freq vector:
f = (0:nfft/2-1)*fs/nfft;

subplot(2,1,2)
plot(f,XX)

figure; 
periodogram(XX)
%}

if nargin < 1

    %% Kaitala et al., Population dynamics and the colour of environmental noise, 1997
    %  The code below for testing purposes only - the real data as an input
    %  for this function.
  
    
    m = 1024; 

    % generating 3xm uniformly distributed number between [-0.5, 0.5]:
    % checking: hist(y)

    y1 = -0.4 + rand(m,1); 
    y2 = -0.4 + rand(m,1); 
    y3 = -0.4 + rand(m,1); 

    % environmental noise:
    red = 0.4; 
    white = 0.0; 
    blue = -0.4;

    d1 = zeros(m,1); 
    d2 = zeros(m,1); 
    d3 = zeros(m,1); 

    %AR-models:
    for ii = 2:m
        d1(ii) = red*d1(ii-1) + y1(ii);
        d2(ii) = white*d2(ii-1) + y2(ii);
        d3(ii) = blue*d3(ii-1) + y3(ii);
    end

    figure(20); 
    subplot(3,1,1);  
    plot(d1); 
    ylim([-1 1]);
    xlim([1 m]);
    title('Red noise'); 

    subplot(3,1,2); 
    plot(d2); 
    ylim([-1 1]);
    xlim([1 m]);
    title('White noise'); 

    subplot(3,1,3); 
    plot(d3); 
    ylim([-1 1]);
    xlim([1 m]);
    title('Blue noise'); 

    
    d1 = d1-mean(d1);
    d2 = d2-mean(d2);
    d3 = d3 - mean(d3);
    Xred = fft(d1);
    Xwhite = fft(d2); 
    Xblue = fft(d3); 

    % taking the first half (mirror symmetry in the spectrum around "frequency"
    % m/2 (usually scaled that m = sampling frequency and m/2 = Nyqvist-frequency)

    Xred_half = abs(Xred(1:m/2));  
    Xwhite_half = abs(Xwhite(1:m/2));
    Xblue_half = abs(Xblue(1:m/2));

    xscale = 0:(m/2 - 1);
    xscale = xscale/m; 

    CinRed = signalColor(Xred_half); 
    CinWhite = signalColor(Xwhite_half); 
    CinBlue = signalColor(Xblue_half);
    text1 = ['Color index:', num2str(CinRed)];
    text2 = ['Color index:', num2str(CinWhite)];
    text3 = ['Color index:', num2str(CinBlue)];




    figure(21); 

    %-------------------------------------- RED NOISE
    subplot(3,2,1);
    plot(xscale, Xred_half);
    xlabel('Frequency');
    ylabel('Magnitude'); 
    title('Red noise');
    ylim([0 1.1*max(Xred_half)]);
    %xlim([1 m]);
    text(0.7*max(xscale), 0.9*max(Xred_half), text1); 

    subplot(3,2,2);
    plot(xscale, log10(Xred_half));
    xlabel('Frequency');
    ylabel('log_{10} Magnitude'); 
    title('Red noise');


    %---------------------------------------WHITE NOISE
    subplot(3,2,3);
    plot(xscale, Xwhite_half);
    xlabel('Frequency');
    ylabel('Magnitude'); 
    title('White noise'); 
    ylim([0 1.1*max(Xwhite_half)]);
    %xlim([1 m]);
    text(0.7*max(xscale), 0.9*max(Xwhite_half), text2); 

    subplot(3,2,4);
    plot(xscale, log10(Xwhite_half));
    xlabel('Frequency');
    ylabel('log_{10} Magnitude'); 
    title('White noise'); 


    %---------------------------------------BLUE NOISE
    subplot(3,2,5);
    plot(xscale, Xblue_half);
    xlabel('Frequency');
    ylabel('Magnitude'); 
    title('Blue noise'); 
    ylim([0 1.1*max(Xblue_half)]);
    %xlim([1 m]);
    text(0.7*max(xscale), 0.9*max(Xblue_half), text3); 

    subplot(3,2,6);
    plot(xscale, log10(Xblue_half));
    xlabel('Frequency');
    ylabel('log_{10}Magnitude'); 
    title('Blue noise'); 
    CinArray = [CinRed, CinWhite, CinBlue];
    %return;
end


[m,n] = size(timeseries); 


% let's plot the timeseries as a series of 12 subplots!

% remaind = 12; 
% fignumb = fix(m/12); 
% if rem(m,12)~=0
%     fignumb = fignumb + 1; 
%     remaind = rem(m,12);  % something else than 12
% end
% 
% for jj = 1:fignumb-1
%     figure(20+jj)
%     clf;    
%     for ii = 1:12
%         subplot(4,3,ii)
%         plot(timeseries(12*(jj-1)+ii,:), 'k--');
%     end
% end
% 
% figure(20 + fignumb);
% clf;
% for ii = 1:remaind
%     subplot(4,3,ii)
%     plot(timeseries(12*(fignumb-1)+ii,:), 'k--');
% end

% FFT analysis => power (abs taken first!) with respect to frequency
tseries = timeseries';
tseries = tseries-mean(tseries); 
spectre = fft(tseries);
mm = fix(n/2);

spectre_half = abs(spectre(1:mm,:));
xscale = 0:(mm-1);
xscale = xscale/n; 

%figure(30)
%plot(xscale, spectre_half);


% FFT plotting: 

% remaind = 12; 
% fignumb = fix(m/12); 
% if rem(m,12)~=0
%     fignumb = fignumb + 1; 
%     remaind = rem(m,12);  % something else than 12
% end
% 
% for jj = 1:fignumb-1
%     figure(40+jj)
%     clf;    
%     for ii = 1:12
%         subplot(4,3,ii)
%         plot(xscale, spectre_half(:, 12*(jj-1)+ii), 'k--');
%     end
% end
% 
% figure(40 + fignumb);
% clf;
% for ii = 1:remaind
%     subplot(4,3,ii)
%     plot(xscale, spectre_half(:, 12*(jj-1)+ii), 'k--');
% end


for ss = 1:m
    CinArray(ss) = signalColor(spectre_half(:,ss));
end






























