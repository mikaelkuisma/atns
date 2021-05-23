function [numPaths, lenPaths] = pathLengths(A, i, j)

AA = full(A);
numPaths = [];
lenPaths = [];
k = 0;
while nnz(AA) > 0
    k = k+1;
    numPaths = [numPaths AA(i,j)]; %#ok<AGROW>
    lenPaths = [lenPaths k]; %#ok<AGROW>
    AA = AA*A;
end