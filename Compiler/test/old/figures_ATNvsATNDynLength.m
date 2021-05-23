load Results\ATNvsATNDynLength.mat

figure(10045)
for i = 1:size(Results.B,1)
    clf
    plot(Results_old.B(i,:))
    hold on
    plot(Results_dynLength.B(i,:))
    pause
end