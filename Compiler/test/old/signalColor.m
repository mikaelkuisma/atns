function f = signalColor(timedata)
% input: time series,
% output: "color" of the signal
% mvesteri April 2018

%p= nextpow2(length(timedata))   % the closest power of two
%nfft = 2^p; % creating number of points for fft (fastest when doing this)
%X = fft(timedata,nfft); 

%X = fft(timedata); 
%XX = abs(X);  % the magnitude of X

N = length(timedata); 

%divs = ceil(N/4); % this was previous value
% new value mijuvest 28.8.2018
divs = ceil(N/2); 

%xscale = (0:Nhalf-1)/Nhalf; 
%divs = floor(Nhalf/4); 

%freq = [0: N-1]*fs/N; 
%f_nyq = fs/2; 

%something small here that we won't divide by zero
% lowersum = 1e-15; 
% uppersum = 1e-15; 
%note: usually, some sort of scaling is made for frequency, but the final
%result does not need that (division of two variables with same units)

%for i = 1:divs
    %lowersum = lowersum + xscale(i)*XX(i); % the "integral" from 0 -> 25 %
    %uppersum = uppersum + xscale(upperstart + i)*XX(upperstart + i); % the "integral" from 75 % -> 100 %  
%end

lowermean = sum(timedata(1:divs))/divs;  % start from element number 2, otherwise peak will be counted

% previously
%uppermean = (sum(timedata(divs+1:2*divs)) + sum(timedata(2*divs+1:3*divs)) + sum(timedata(3*divs+1:end)))/(3*divs);
% new value mijuvest 28.8.2018
uppermean = sum(timedata(divs+1:end))/divs;

% to avoid Infs
%if uppermean < 1e-20
%    f = 1 ;
%end
%  if uppermean < 1e-10
%      f = 1;
%  else
%      f = lowermean/uppermean; 
%  end

f = lowermean/uppermean;









