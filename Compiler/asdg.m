for C = linspace(2,4,500)
data=[];
SSB=0.2;
CC = 1;
for i=1:1000
    SSB = C*SSB * (1-SSB/CC);
    data(i)=SSB;
end
hist(data, linspace(0,1,400));
pause(0.1);
end
    