function [X, sumY] = diricrnd(alpha, m)

if nargin < 2
    m = 1;
end

[k, n] = size(alpha);

if k == 1 || n == 1
    Alpha = repmat(alpha(:)', m, 1);
else
    Alpha = alpha;
end

Y = gamrnd(Alpha, 1);
sumY = sum(Y, 2);
X = Y./sumY;

