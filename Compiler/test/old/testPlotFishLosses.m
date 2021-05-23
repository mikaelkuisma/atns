function testPlotFishLosses(Results, Data)

try
    close(21:29)
catch
end

t = (Data.burn_in+1):Data.end_recovery;

for j = 1:Data.GuildInfo.nFishSpecies
    
    f = figure(20+j);
    f.Name = sprintf('Fish %i - average losses', j);
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    
    for i = 1:5
        subplot(5,1,i)
        ind = 5*(j-1)+Data.GuildInfo.iFishGuilds(1)+(i-1);
        
        if size(Data.adjacencyMatrix,1) >= ind
            predatorInds = find(Data.adjacencyMatrix(:,ind));
            XData = 1:length(predatorInds);
            L = mean(squeeze(Results.G(predatorInds,ind,t))');
            YData = L;
            title(sprintf('Average losses: %s', Data.Guilds(ind).name))
            XTickLabels = {Data.Guilds(predatorInds).label};
            XTickLabels = cellfun(@(x)sprintf('%s', x), XTickLabels, 'UniformOutput', false);
            set(gca, 'XTickLabel', XTickLabels)
            
        else
            YData = NaN;
            XData = NaN;
        end
        
        hold on
        bar(XData, YData)
        
        box off
        set(gca, 'tickdir', 'out')
        set(gca, 'XTick', XData)
        set(gca, 'FontSize', 10)
    end
    print(20+j, sprintf('figure_%i.png',20+j),'-dpng','-r300')
end


