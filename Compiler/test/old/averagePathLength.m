function avgLen = averagePathLength(A, i, j)

[numPaths, lenPaths] = pathLengths(A, i, j);

avgLen = numPaths*lenPaths'/sum(numPaths);