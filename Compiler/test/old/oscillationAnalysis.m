clear
close all
gears = {'LargeMesh', 'SmallMesh'};
load Data\1_LakeConstance.mat

firstPeak = [14 16 15 15 ; 16 14 15 15]';
for j = 1:2
    allBiomasses = load([gears{j} '_0.75_allbiomasses_200years.txt']);
    
    if j == 1
        iFished = [25 26 27 32];
    elseif j == 2
        iFished = [25 26 27 30 31 32];
    end
    iProducers = 3:8;
    iZooplankton = 9:22;
    iDOC = 1:2;
    iNonFished = setdiff(1:32,[iFished iProducers iZooplankton iDOC]);
    
    B(1,:) = sum(allBiomasses(iFished,1:91:end));
    B(2,:) = sum(allBiomasses(iNonFished,1:91:end));
    B(3,:) = sum(allBiomasses(iProducers,1:91:end));
    B(4,:) = sum(allBiomasses(iZooplankton,1:91:end));
    
    labels = {'Fished species', 'Non-fished species', 'Producers', 'Zooplankton'};
    
    for i = 1:size(B, 1)
        x = B(i,:);
        
        x1 = x(1:100);
        x2 = x(101:end);
        
        t1 = 1:100;
        t2 = 100+(1:length(x2));
        
        %
        lw = 1;
        figure(j*100+i)
        set(gcf,'Units','normalized')
        set(gcf,'Position',[0 0 1 1])
        clf
        subplot(2,1,1)
        plot(t1,x1,'.-r','linewidth',lw, 'markersize', 14)
        hold on
        plot(t2,x2,'.-r','linewidth',lw)
        
        %
        pars1 = fitWave(t1, x1);
        
        weights2 = ones(size(x2));
        iPriorityZero = 1:10;
        weights2(iPriorityZero) = 0;
        iPriorityHigh = firstPeak(i,j):4:length(x2);
        weights2(iPriorityHigh) = 10;
        pars2 = fitWave(t2, x2, 'weights', weights2);
        iPriorityNormal = find(weights2 == 1);
        
        plot(t1, waveFcn(pars1, t1), ':b', 'linewidth', lw)
        plot(t2, waveFcn(pars2, t2), ':b', 'linewidth', lw)
        plot(t2(iPriorityHigh), x2(iPriorityHigh), 'dr', 'linewidth', lw+1, 'markersize', 8)
        plot(t2(iPriorityZero), x2(iPriorityZero), 'xr', 'linewidth', lw, 'markersize', 8)
        plot(t2(iPriorityNormal), x2(iPriorityNormal), '.r', 'markersize', 14)
        box off
        set(gca,'TickDir','out')
        title([labels{i} ', ' gears{j} ', Data and fit'])
        xlabel('Year')
        ylabel('Density')
        set(gca,'fontsize',18)
        axis tight
        ylim = get(gca,'YLim');
        set(gca,'ylim',[ylim(1) 0.2*diff(ylim)+ylim(2)])
        plot([100 100],get(gca,'ylim'),'--k')
        text(10, 0.1*diff(ylim)+ylim(2), ...
            sprintf('mean: %.3e, amplitude: %.3e, half-life: %.3e', pars1(1), pars1(2), log(2)/pars1(5)), ...
            'fontsize', 14)
        text(110, 0.1*diff(ylim)+ylim(2), ...
            sprintf('mean: %.3e, amplitude: %.3e, half-life: %.3e', pars2(1), pars2(2), log(2)/pars2(5)), ...
            'fontsize', 14)        
        
        disp(gears{j})
        disp(labels{i})
        disp(sprintf('mean: %.3e, amplitude: %.3e (%.3e), half-life: %.3e', pars1(1), pars1(2), pars1(2)/pars1(1), log(2)/pars1(5)))
        disp(sprintf('mean: %.3e, amplitude: %.3e (%.3e), half-life: %.3e', pars2(1), pars2(2), pars2(2)/pars2(1), log(2)/pars2(5)))
        
        %
        subplot(2,1,2)
        err1 = x1 - waveFcn(pars1, t1);
        relerr1 = abs(err1)./x1;
        err2 = x2 - waveFcn(pars2, t2);
        relerr2 = abs(err2)./x2;
        plot(t1, relerr1, '-r', 'linewidth', lw)
        hold on
        plot(t2, relerr2, '-r', 'linewidth', lw)
        plot(t2(iPriorityHigh), relerr2(iPriorityHigh), 'db', 'linewidth', lw+1, 'markersize', 8)
        plot(t2(iPriorityZero), relerr2(iPriorityZero), 'xb', 'linewidth', lw, 'markersize', 8)
        plot(t2(iPriorityNormal), relerr2(iPriorityNormal), '.b', 'markersize', 14)
        box off
        set(gca,'TickDir','out')
        title('Goodness of fit')
        xlabel('Year')
        ylabel('Relative absolute error')
        set(gca,'fontsize',18)
        axis tight
        plot([100 100],get(gca,'ylim'),'--k')
        
        print([gears{j} '_' labels{i} '.png'],'-dpng','-r300')
    end
end