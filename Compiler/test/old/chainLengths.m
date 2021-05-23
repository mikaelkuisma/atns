function [nn, l, avgl, sumsumN] = chainLengths(A, I_top, I_bottom)

if nargin < 2
    I_top = topNodes(A);
end
if nargin < 3
    I_bottom = bottomNodes(A);
end

nn = [];
for i = 1:length(I_top)
    for j = 1:length(I_bottom)
        [n, l] = pathLengths(A, I_top(i), I_bottom(j));
        nn = [nn ; n];
    end
end

sumN = sum(nn, 1);
sumsumN = sum(sumN);
avgl = sumN*l'/sumsumN;