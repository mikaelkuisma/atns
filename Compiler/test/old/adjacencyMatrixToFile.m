function adjacencyMatrixToFile(filename, A)
filename
fid = fopen(filename, 'wt');
A = full(A);
for i = 1:size(A,1)
    fprintf(fid, '%i,', A(i,1:end-1));
    fprintf(fid, '%i\n', A(i,end));
end
fclose(fid);