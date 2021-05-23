GI = Data.GuildInfo;
T = 51:200;
%%
figure(1)
Is = GI.iDetritusGuilds;
for i = 1:length(Is)
    subplot(1,2,i)
    I = Is(i);
    plot(Results.B(I,T))
    title(Data.Guilds(I).label)
    box off
    set(gca,'tickdir','out')
end
%%
figure(2)
Is = GI.iProducerGuilds;
for i = 1:length(Is)
    subplot(3,3,i)
    I = Is(i);
    plot(Results.B(I,T))
    title(Data.Guilds(I).label)
    box off
    set(gca,'tickdir','out')
end
%%
figure(3)
Is = GI.iConsumerGuilds;
for i = 1:length(Is)
    subplot(3,6,i)
    I = Is(i);
    plot(Results.B(I,T))
    title(Data.Guilds(I).label)
    box off
    set(gca,'tickdir','out')
end
%%
figure(4)
Is = GI.iFishGuilds;
for i = 1:length(Is)
    subplot(5,9,i)
    I = Is(i);
    plot(Results.B(I,T))
    title(Data.Guilds(I).label)
    box off
    set(gca,'tickdir','out')
end