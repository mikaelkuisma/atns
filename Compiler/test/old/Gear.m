classdef Gear
    %GEAR fishing gear object for ATN simulations
    %
    
    properties
        Name
        SelectionBy
        SelectionCurve
        ProportionReleased
    end
    
    methods
        function obj = Gear(varargin)
            %GEAR Construct an instance of this class
            %
            gearName = lower(varargin{1});
            switch gearName
                case 'small-mesh net'
                    selectionBy = 'length';
                    mu = 20;
                    sigma = 3;
                    selectionCurve = @(x)exp(-(x-mu).^2/(2*sigma^2));
                case 'large-mesh net'
                    selectionBy = 'length';
                    mu = 30;
                    sigma = 4;
                    selectionCurve = @(x)exp(-(x-mu).^2/(2*sigma^2));
                case 'fyke net'
                    if nargin >= 2 && isnumeric(varargin{2}) ...
                            && all(varargin{2} >= 0) && all(varargin{2} <= 1)
                        obj.ProportionReleased = varargin{2};
                    else
                        obj.ProportionReleased = 0;
                    end
                    selectionBy = 'length';
                    a = 10;
                    b = 0.5;
                    selectionCurve = @(x)exp(a+b*x)./(1+exp(a+b*x));
                case 'hatchery-test'
                    selectionBy = 'age';
                    Stest = [0 0 1/3 2/3 1]';
                    selectionCurve = @(x)Stest(x+1);
                case 'stochasticity-simulations'
                    selectionBy = 'age';
                    a50 = 3;
                    Stest = [1./(1 + exp(-2*((0:3) - a50))) 1]';
                    selectionCurve = @(x)Stest(x+1);
                case 'lake-vorts'
                    selectionBy = 'length';
                    p = 1e-2 * [ ...
                        5.7 ...                 % Roa4
                        3.8 3.8 3.8 3.8 ...     % Bre1-4
                        5.2 ...                 % Ruf4
                        8.1 8.1 ...             % Per3-4
                        14.3 14.3 14.3 ...      % Eel2-4
                        4 ...                   % Ppe4
                        22.5 22.5 22.5 ...      % Pik2-4
                        ];
                    F = -log(1-p);
                    lengths = [ ...
                        11.9 ...                % Roa4
                         9.2 14.5 19.0 22.4 ... % Bre1-4
                         9.7 ...                % Ruf4
                        13.0 17.4 ...           % Per3-4
                        27.7 36.2 44.6 ...      % Eel2-4
                        41.0 ...                % Ppe4
                        30.0 38.0 43.7 ...      % Pik2-4
                        ];
                    selectionCurve = @(x)arrayfun(@(y)F(y == lengths),x,'UniformOutput',false);
                case 'rectangle'
                    iParams = find(strcmpi(varargin, 'interval'));
                    Params = [0 0];
                    if ~isempty(iParams) && nargin > iParams
                        Params = varargin{iParams+1};
                    end
                    selectionBy = 'length';
                    %selectionCurve = @(x)heaviside(x-Params(1))-heaviside(x-Params(2));
                    selectionCurve = @(x)(x>=Params(1)) & (x<=Params(2)); 
                case 'none'
                    selectionBy = 'none';
                    selectionCurve = @(x)0;
                otherwise
                    error('Unknown gear type')
            end
            
            obj.Name = gearName;
            obj.SelectionBy = selectionBy;
            obj.SelectionCurve = selectionCurve;
        end
        
        function s = selectivity(obj,FishGuilds)
            %MORTALITYRATE
            %
            if strcmp(obj.SelectionBy,'none')
                s = zeros(length(FishGuilds),1);
            else
                if isstruct(FishGuilds)
                    isCatchable = vertcat(FishGuilds.catchable);
                    lengths = vertcat(FishGuilds.avgl);
                    ages = vertcat(FishGuilds.age);
                    switch obj.SelectionBy
                        case 'length'
                            selectionVariable = lengths;
                        case 'age'
                            selectionVariable = ages;
                        otherwise
                            error('Undefined gear SelectionBy')
                    end
                elseif isvector(FishGuilds)
                    isCatchable = ones(size(FishGuilds));
                    selectionVariable = FishGuilds;
                end
                    
                s = obj.SelectionCurve(selectionVariable);
                if iscell(s)
                    iEmpty = find(cellfun(@isempty,s))';
                    for i = iEmpty
                        s{i} = 0;
                    end
                    s = cell2mat(s);
                end
                s = s.*isCatchable;
                if ~isempty(obj.ProportionReleased)
                    if isscalar(obj.ProportionReleased)
                        s = (1 - (ages == max(ages))*obj.ProportionReleased).*s;
                    else
                        s = (1 - obj.ProportionReleased(:)).*s;
                    end
                end
            end
        end
    end
end
    
