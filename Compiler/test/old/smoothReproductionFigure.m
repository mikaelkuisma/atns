L = pi;

dfmax = 1;
x0 = L;
k = 5/L;

xx = linspace(0,2*L,1e4);
df = @(x)dfmax./(1+exp(-k*(x-x0)));
f = @(x)(dfmax*(log(exp(-k*(x - x0)) + 1) + k*x))/k-L;

figure(1)
clf
subplot(211)
plot(xx,df(xx),'-b','linewidth',2)
hold on
plot(xx(xx > L),(xx(xx > L) > L),':r','linewidth',2)
plot(xx(xx < L),(xx(xx < L) > L),':r','linewidth',2)
axis tight
plot([L L],get(gca,'ylim'),'--k','linewidth',1)
box off
set(gca,'tickdir','out')
set(gca,'xtick',linspace(0.5*L,1.5*L,3))
set(gca,'xticklabel',{'G < L','G = L','G > L'})
set(gca,'ytick',[])
set(gca,'TickLength',[0 0])
set(gca,'LineWidth',1)
xlabel('Consumption gains (G)')


subplot(212)
plot(xx,f(xx),'-b','linewidth',2)
hold on
plot(xx,(xx > L).*(xx-L),':r','linewidth',2)
axis tight
plot([L L],get(gca,'ylim'),'--k','linewidth',1)
box off
set(gca,'tickdir','out')
set(gca,'xtick',linspace(0.5*L,1.5*L,3))
set(gca,'xticklabel',{'G < L','G = L','G > L'})
set(gca,'ytick',[])
set(gca,'TickLength',[0 0])
set(gca,'LineWidth',1)
xlabel('Consumption gains (G)')
