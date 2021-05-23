for j = 1:3
    figure(12+j)
    clf
    
    for i = 1:5
        if j == 3 && i == 5
            break
        end
        subplot(5,1,i)
        ind = 5*(j-1)+9+(i-1);
        G = Results.G(ind,:,y0);
        preyInds = find(Data.adjacencyMatrix(ind,:));
        avgB = mean(Results.allbiomasses(ind,(y0-1)*Data.ltspan+1:y0*Data.ltspan));
        YData = G/avgB;
        bar(preyInds, YData(preyInds))
        title(sprintf('Gains per average density: %s (%i)', Data.Guilds(ind).label, ind))
        box off
        set(gca, 'tickdir', 'out')
        %set(gca, 'XTick', 1:32)
        %set(gca, 'XTickLabel', 1:32)
        XTickLabels = {Data.Guilds(preyInds).label};
        XTickLabels = cellfun(@(x,y)sprintf('%s (%i)', x, y), XTickLabels, num2cell(preyInds), 'UniformOutput', false);
        set(gca, 'XTickLabel', XTickLabels)
        %set(gca, 'XLim', [15.5 29.5])
        set(gca, 'FontSize', 12)
        
    end
    
end