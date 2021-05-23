function guildLabelsToFile(filename, Guilds)

fid = fopen(filename, 'wt');
for i = 1:length(Guilds)
    fprintf(fid, '%s\n', Guilds(i).label);
end
fclose(fid);