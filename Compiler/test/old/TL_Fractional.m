function T2 = TL_Fractional(W)

% Compute path-based trophic levels. (Levine 1980)
% C=I+Q+Q^2+Q^3+.... is a geometric series & converges -> C=(I-Q)^(-1)

% Create weighted Q matrix that gives proportion of the diet given by each prey species.
Q=W./sum(W,2);  % Create weighted Q matrix. (Proportion of predator diet that each species gives).
Q(isnan(Q))=0;  % Set NaN values to 0.

N = size(W,1);
% Calculate trophic levels as T2=(I-Q)^-1 * 1  %Levine 1980 geometric series
%T2=(inv(eye(N)-Q))*ones(N,1); % Or sum over the rows "sum(A,2)"
T2 = (eye(N)-Q)\ones(N,1);
