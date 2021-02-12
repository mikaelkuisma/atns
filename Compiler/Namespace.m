classdef Namespace < handle & matlab.mixin.CustomDisplay
    properties
        fields
    end
   methods (Access = protected)
      function displayScalarObject(obj)
          k = keys(obj.fields);
          vals = values(obj.fields);
          for i=1:numel(k)
              disp(sprintf('%s = %f;', k{i}, vals{i}));
          end
      end
   end
    methods
        function obj = Namespace()
            obj.fields = containers.Map;
        end
        
        function value = subsref(obj,s)
            if (s.type == '.')
                value = obj.fields(s.subs);
            else
                error('Internal error.');
            end
        end
        
        function obj = subsasgn(obj,s,varargin)
            if (s.type == '.')
                obj.fields(s.subs) = varargin{1};
            else
                error('Internal error.');
            end
        end
        
        
    end
end