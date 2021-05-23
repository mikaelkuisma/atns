figure(400)
clf
for i = 3:32
    subplot(6,5,i-2)
    bar(sigmas(i-2,:)/sigmas(i-2,1)*100)
    title(sprintf('%i: %s', i, Data.Guilds(i).label))
    box off
    set(gca, 'TickDir', 'out')
    set(gca, 'YLim', [0 300])
    set(gca, 'XTickLabel', {'Before', 'During', 'After'})
    title(sprintf('%i: %s', i, Data.Guilds(i).label))
end
ht = text(0,0,'Relative standard deviation');
ht.FontSize = 20;
ht.Position = [-14 3830 0];