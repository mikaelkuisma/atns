function saveResults(Results,ResultOptions,GI)

fid = fopen([ResultOptions.Directory ResultOptions.File],'wt');
for irow = 1:size(Results.allbiomasses,2)
    fprintf(fid,[repmat('%.6e ',1,GI.nGuilds-1) '%.6e\n'], ...
        Results.allbiomasses(:,irow)');
end
fclose(fid);