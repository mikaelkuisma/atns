function guildColorsToFile(filename, Guilds)

colors = {'#C9C9C9', '#2A7F40', '#AA7139', '#6E94D4'};
types = {'Detritus', 'Producer', 'Consumer', 'Fish'};

fid = fopen(filename, 'wt');
for i = 1:length(Guilds)
    color = colors{strcmp(Guilds(i).type, types)};
    fprintf(fid, '%s\n', color);
end
fclose(fid);