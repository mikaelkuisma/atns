function testPlotFishBiomasses(Results, Data)

plotDetritus = false;
plotProducers = true;
plotConsumers = true;
plotFish = true;

lw = 1;

try
    close(1:5)
catch
end

GI = Data.GuildInfo;

t = 50*Data.ltspan:Data.ltspan:Data.end_recovery*Data.ltspan;
%%
if plotDetritus
    figure(1)
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    Is = GI.iDetritusGuilds;
    for i = 1:length(Is)
        subplot(1,2,i)
        I = Is(i);
        hold on
        %plot(Results.B(I,T), 'linewidth', lw)
        plot(Results.allbiomasses(I,t), 'linewidth', lw)
        title(Data.Guilds(I).label)
        box off
        set(gca,'tickdir','out')
    end
end
%%
if plotProducers
    figure(2)
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    Is = GI.iProducerGuilds;
    for i = 1:length(Is)
        subplot(3,3,i)
        I = Is(i);
        hold on
        %plot(Results.B(I,T), 'linewidth', lw)
        plot(Results.allbiomasses(I,t), 'linewidth', lw)
        title(Data.Guilds(I).label)
        box off
        set(gca,'tickdir','out')
    end
end
%%
if plotConsumers
    figure(3)
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    Is = GI.iConsumerGuilds;
    for i = 1:length(Is)
        subplot(3,6,i)
        I = Is(i);
        hold on
        %plot(Results.B(I,T), 'linewidth', lw)
        plot(Results.allbiomasses(I,t), 'linewidth', lw)
        title(Data.Guilds(I).label)
        box off
        set(gca,'tickdir','out')
    end
end
%%
if plotFish
    figure(4)
    set(gcf, 'units', 'normalized')
    set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
    %Is = GI.iFishGuilds;
    Is = [30:69 70 71 72 73 74];
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
        subplot(5,9,Js(i))
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
                set(gcf, 'units', 'normalized')
                set(gcf, 'OuterPosition', [0.05 0.05 0.9 0.9])
                subplot(3,3,iFish)
                title(Data.Guilds(I).label(1:3))
                hold on
                plot(Y2Data, 'linewidth', lw)
                box off
                set(gca, 'tickdir', 'out')
                figure(4)
            end
            
        else
            YData = NaN./allFishB;
        end
        plot(YData, 'linewidth', lw)
        
        box off
        set(gca, 'tickdir', 'out')
        set(gca, 'yticklabel', ...
            cellfun(@(x)sprintf('%.4f',x), num2cell(get(gca, 'YTick')), 'UniformOutput', false))
    end
end
