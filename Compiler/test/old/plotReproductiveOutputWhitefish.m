figure(102)
clf
for i = 1:3
    GF = Results.GF(3+(i-1),:);
    avgB = mean(Results.allbiomasses(25+(i-1),(y0-1)*Data.ltspan+1:y0*Data.ltspan));
    YData = GF/avgB;
    plot(YData, 'LineWidth', 2)
    hold on
end
box off
set(gca, 'XLim', [Data.end_burnin+1 Data.end_recovery])
set(gca, 'TickDir', 'out')
legend('Whi2', 'Whi3', 'Whi4+')
title('Reproductive output per average density')