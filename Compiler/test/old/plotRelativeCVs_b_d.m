figure(300)
clf
for i = 3:32
    subplot(6,5,i-2)
    bar(cvs(i-2,1:2)/cvs(i-2,1)*100)
    title(sprintf('%i: %s', i, Data.Guilds(i).label))
    box off
    set(gca, 'TickDir', 'out')
    set(gca, 'YLim', [0 200])
    set(gca, 'XTickLabel', {'Before', 'During'})
    title(sprintf('%i: %s', i, Data.Guilds(i).label))
end
ht = text(0, 0, 'Relative coefficient of variation');
ht.FontSize = 20;
ht.Units = 'normalized';
ht.Position = [-3 9.8 0];
