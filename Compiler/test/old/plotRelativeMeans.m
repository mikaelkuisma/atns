figure(500)
clf
for i = 3:32
    subplot(6,5,i-2)
    bar(mus(i-2,:)/mus(i-2,1)*100)
    box off
    set(gca, 'TickDir', 'out')
    set(gca, 'YLim', [0 150])
    set(gca, 'XTickLabel', {'Before', 'During', 'After'})
    title(sprintf('%i: %s', i, Data.Guilds(i).label))
end
ht = text(0,0,'Relative mean');
ht.FontSize = 20;
ht.Position = [-12 1900 0];