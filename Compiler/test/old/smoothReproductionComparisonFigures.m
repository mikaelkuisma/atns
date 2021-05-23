webdriver_2
Results_3 = Results;
%%
webdriver_3
Results_2 = Results;
%%
webdriver
Results_1 = Results;

%%
for j = 1:2
    figure(j)
    clf
    for i = 1:5
        subplot(2,5,i)
        plot(Results_1.B(22+(j-1)*5+i,1:end))
        hold on
        plot(Results_2.B(22+(j-1)*5+i,1:end))
        plot(Results_3.B(22+(j-1)*5+i,1:end))
        axis tight
        plot([1 1]*start_fishing,get(gca,'ylim'),'--k')
        plot([1 1]*end_fishing,get(gca,'ylim'),'--k')
        title(sprintf('B (%i-y)',i-1))
    
        subplot(2,5,5+i)
        plot(Results_1.GF((j-1)*5+i,1:end))
        hold on
        plot(Results_2.GF((j-1)*5+i,1:end))
        plot(Results_3.GF((j-1)*5+i,1:end))
        axis tight
        plot([1 1]*start_fishing,get(gca,'ylim'),'--k')
        plot([1 1]*end_fishing,get(gca,'ylim'),'--k')
        title(sprintf('GF (%i-y)',i-1))
    end
    subplot(2,5,6)
    legend('Orig', 'Smooth old', 'Smooth new')
end

%%
webdriver_2b
Results_3b = Results;
webdriver_2c
Results_3c = Results;
%%

for j = 1:2
    figure(j+2)
    clf
    for i = 1:5
        subplot(2,5,i)
        plot(Results_3.B(22+(j-1)*5+i,1:end))
        hold on
        plot(Results_3b.B(22+(j-1)*5+i,1:end))
        plot(Results_3c.B(22+(j-1)*5+i,1:end))
        axis tight
        plot([1 1]*start_fishing,get(gca,'ylim'),'--k')
        plot([1 1]*end_fishing,get(gca,'ylim'),'--k')
        title(sprintf('B (%i-y)',i-1))
    
        subplot(2,5,5+i)
        plot(Results_3.GF((j-1)*5+i,1:end))
        hold on
        plot(Results_3b.GF((j-1)*5+i,1:end))
        plot(Results_3c.GF((j-1)*5+i,1:end))
        axis tight
        plot([1 1]*start_fishing,get(gca,'ylim'),'--k')
        plot([1 1]*end_fishing,get(gca,'ylim'),'--k')
        title(sprintf('GF (%i-y)',i-1))
    end
    subplot(2,5,6)
    legend('c = 0.25', 'c = 0.5', 'c = 1')
end

%%

figure(5)
clf
plot(sum(Results_1.B(:,1:end)))
hold on
plot(sum(Results_2.B(:,1:end)))
plot(sum(Results_3.B(:,1:end)))
axis tight
plot([1 1]*start_fishing,get(gca,'ylim'),'--k')
plot([1 1]*end_fishing,get(gca,'ylim'),'--k')
title('Btot')
legend('Orig', 'Smooth old', 'Smooth new')

figure(6)
clf
plot(sum(Results_3.B(:,1:end)))
hold on
plot(sum(Results_3b.B(:,1:end)))
plot(sum(Results_3c.B(:,1:end)))
axis tight
plot([1 1]*start_fishing,get(gca,'ylim'),'--k')
plot([1 1]*end_fishing,get(gca,'ylim'),'--k')
title('Btot')
legend('c = 0.25', 'c = 0.5', 'c = 1')
