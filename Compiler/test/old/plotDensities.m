fig = figure(200);
fig.Name = 'Density';
clf
padd = 5;
dark = 0.75;
for i = 3:32
    subplot(6,5,i-2)
    B = Results.allbiomasses(i,Data.ltspan:Data.ltspan:end);
    tspan = Data.end_burnin+1:Data.end_recovery;
    YData = B(tspan);
    plot(tspan, YData, '-k', 'LineWidth', 2)
    box off
    set(gca, 'TickDir', 'out')
    axis tight
    title(sprintf('%i: %s', i, Data.Guilds(i).label))
    
    %set(gca,'XLim', [Data.end_burnin+1 Data.end_recovery])
    %set(gca,'YLim', [0 2*mean(B)])
    
    I1 = (Data.end_burnin+1+padd):(Data.start_fishing-padd-1);
    I2 = (Data.start_fishing+padd):(Data.end_fishing-padd);
    I3 = (Data.end_fishing+1+padd):(Data.end_recovery-padd);
    
    hold on
    YLim = get(gca,'YLim');
    hf = fill(I1([1 1 end end]), [YLim(1) YLim(2) YLim(2) YLim(1)], dark*ones(1,3));
    hf.LineStyle = 'none';
    hf.FaceAlpha = 0.5;
    uistack(hf, 'bottom')
    hf = fill(I2([1 1 end end]), [YLim(1) YLim(2) YLim(2) YLim(1)], dark*ones(1,3));
    hf.LineStyle = 'none';
    hf.FaceAlpha = 0.5;
    uistack(hf, 'bottom')
    hf = fill(I3([1 1 end end]), [YLim(1) YLim(2) YLim(2) YLim(1)], dark*ones(1,3));
    hf.LineStyle = 'none';
    hf.FaceAlpha = 0.5;
    uistack(hf, 'bottom')

    B1 = B(I1);
    B2 = B(I2);
    B3 = B(I3);
    
    mus(i-2,:) = [mean(B1) mean(B2) mean(B3)];
    sigmas(i-2,:) = [std(B1) std(B2) std(B3)];
end

cvs = sigmas./mus;
fprintf('Relative CVs\n')
fprintf('\t%i \t%.0f \t%.1f \t\t%.1f\n',[(3:32)' cvs./cvs(:,1)*100]')