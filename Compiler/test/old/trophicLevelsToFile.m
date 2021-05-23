function trophicLevelsToFile(filename, A)

fid = fopen(filename, 'wt');
TL = TL_PreyAveraged(A);
for i = 1:length(TL)
    fprintf(fid, '%f\n', TL(i));
end
fclose(fid);