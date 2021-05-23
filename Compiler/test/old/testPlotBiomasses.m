function testPlotBiomasses(Results, Data)

plotDetritus = true;
plotProducers = true;
plotConsumers = true;
plotFish = true;

lw = 1;

try
    close(1:5)
catch
end

GI = Data.GuildInfo;

t = [Data.burn_in*Data.ltspan+1 (Data.burn_in+1)*Data.ltspan:Data.ltspan:Data.end_recovery*Data.ltspan];
%%
if plotDetritus && Data.GuildInfo.nDetritusGuilds > 0
    f = figure(1);
    f.Name = 'Detritus';
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    Is = GI.iDetritusGuilds;
    for i = 1:length(Is)
        subplot(1,2,i)
        I = Is(i);
        hold on
        %plot(Results.B(I,T), 'linewidth', lw)
        plot(0:length(t)-1,Results.allbiomasses(I,t), 'linewidth', lw)
        title(Data.Guilds(I).label)
        box off
        set(gca,'tickdir','out')
    end
    print(1, 'figure_1.png','-dpng','-r300')
end
%%
if plotProducers && Data.GuildInfo.nProducerGuilds > 0
    f = figure(2);
    f.Name = 'Producers';
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    Is = GI.iProducerGuilds;
    for i = 1:length(Is)
        subplot(3,3,i)
        I = Is(i);
        hold on
        %plot(Results.B(I,T), 'linewidth', lw)
        plot(0:length(t)-1,Results.allbiomasses(I,t), 'linewidth', lw)
        title(Data.Guilds(I).label)
        box off
        set(gca,'tickdir','out')
    end
    print(2, 'figure_2.png','-dpng','-r300')
end
%%
if plotConsumers && Data.GuildInfo.nConsumerGuilds > 0
    f = figure(3);
    f.Name = 'Consumers';
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    Is = GI.iConsumerGuilds;
    for i = 1:length(Is)
        subplot(3,6,i)
        I = Is(i);
        hold on
        %plot(Results.B(I,T), 'linewidth', lw)
        plot(0:length(t)-1,Results.allbiomasses(I,t), 'linewidth', lw)
        title(Data.Guilds(I).label)
        box off
        set(gca,'tickdir','out')
    end
    print(3, 'figure_3.png','-dpng','-r300')
end
%%
if plotFish && Data.GuildInfo.nFishGuilds > 0
    f = figure(4);
    f.Name = 'Fish age classes';
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    f = figure(5);
    f.Name = 'Fish species';
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    Is = GI.iFishGuilds;
    if ~isempty(Is)
        %Is = [30:69 70 71 72 73 74];
        A = 1:length(Is);
        b = length(Is)/5;
        Js = repmat(1+(A(1:5)-1)*b, 1, b) + fix((A-1)/5);
        
        if size(Results.B,1) >= Is(end)
            allFishB = sum(Results.allbiomasses(Is,t));
        else
            allFishB = sum(Results.allbiomasses(Is(1:end-5),t));
        end
        
        iFish = 0;
        for i = 1:length(Is)
            figure(4)
            subplot(5,Data.GuildInfo.nFishSpecies,Js(i))
            I = Is(i);
            hold on
            if I <= size(Results.B, 1)
                %YData = Results.B(I,T);
                YData = Results.allbiomasses(I,t);
                title(Data.Guilds(I).label)
                
                YData = YData./allFishB;
                
                if Data.Guilds(I).age == 4
                    iFish = iFish + 1;
                    fishB = sum(Results.allbiomasses(I-4:I,t));
                    Y2Data = fishB./allFishB;
                    figure(5)
                    subplot(3,3,iFish)
                    title(Data.Guilds(I).label(1:3))
                    hold on
                    plot(0:length(t)-1,Y2Data, 'linewidth', lw)
                    box off
                    set(gca, 'tickdir', 'out')
                    figure(4)
                end
                
            else
                YData = NaN./allFishB;
            end
            plot(0:length(t)-1,YData, 'linewidth', lw)
            
            box off
            set(gca, 'tickdir', 'out')
            set(gca, 'yticklabel', ...
                cellfun(@(x)sprintf('%.4f',x), num2cell(get(gca, 'YTick')), 'UniformOutput', false))
        end
    end
    print(4, 'figure_4.png','-dpng','-r300')
    print(5, 'figure_5.png','-dpng','-r300')
end
