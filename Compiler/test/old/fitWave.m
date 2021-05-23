function pars = fitWave(x, y, varargin)
% x - time steps
% y - time series to be modelled
% varargin - key-value pairs of options

if mod(length(varargin),2)
   error('Invalid number of input arguments.') 
end

n = 2;
% A = []; b = []; Aeq = []; beq = [];
pars0 = [ mean(y) ; std(y) ; 4 ; 0 ; 0 ; x(1) ];
weights = ones(size(y));

for i = 1:2:length(varargin)
    key = varargin{i};
    if ~ischar(key)
        error('Key must be a string.')
    end
    
    value = varargin{i+1};
    switch key
        case 'norm'
            % **TODO** Check that value is proper
            n = value;
        % case 'constraints'
        %     if ~isstruct(value)
        %         error('Constraints must be given as a struct.')
        %     end
        % 
        %     if isfield(value, 'A') && isfield(value, 'b')
        %         A = value.A;
        %         b = value.b;
        %     end
        % 
        %     if isfield(value, 'Aeq') && isfield(value, 'beq')
        %         Aeq = value.Aeq;
        %         beq = value.beq;
        %     end
        case 'init'
            if ~isstruct(value)
                error('Initial parameter values must be given as a struct.')
            end
            
            if isfield(value, 'level')
                pars0(1) = value.level;
            end

            if isfield(value, 'amplitude')
                pars0(2) = value.amplitude;
            end

            if isfield(value, 'period')
                pars0(3) = value.period;
            end

            if isfield(value, 'phase')
                pars0(4) = value.phase;
            end

            if isfield(value, 'dampingFactor')
                pars0(5) = value.dampingFactor;
            end

            if isfield(value, 'shift')
                pars0(6) = value.shift;
            end
        case 'weights'
            if ~isnumeric(value) || ~isequal(size(y), size(value))
                error('Weight vector and time series dimensions do not match.')
            end
            weights = value;
    end
end


objFcn = @(v)norm( weights .* (y - waveFcn(v, x)), n );

pars = fminsearch(objFcn, pars0);
% pars = fmincon(objFcn, pars0, A, b, Aeq, beq);

