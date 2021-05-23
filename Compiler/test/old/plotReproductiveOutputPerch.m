figure(101)
clf
for i = 1:3
    GF = Results.GF(8+(i-1),:);
    avgB = mean(Results.allbiomasses(30+(i-1),(y0-1)*Data.ltspan+1:y0*Data.ltspan));
    YData = GF/avgB;
    plot(YData, 'LineWidth', 2)
    hold on
end
box off
set(gca, 'XLim', [Data.end_burnin+1 Data.end_recovery])
set(gca, 'TickDir', 'out')
legend('Per2', 'Per3', 'Per4+')
title('Reproductive output per average density')
