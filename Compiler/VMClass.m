classdef VMClass < handle & matlab.mixin.CustomDisplay
    properties
        name
        entry_names
        entry_points
        dynamic_names
        parameter_names
        tags
    end
    methods (Access = protected)
      function displayScalarObject(obj)
          fprintf('*****************************\n');
          fprintf('* %-26s*\n', obj.name);
          fprintf('*****************************\n');
          fprintf('*PARAMETERS                 *\n');
          for i=1:numel(obj.parameter_names)
              fprintf('* %-26s*\n', obj.parameter_names{i});
          end
          if numel(obj.parameter_names) == 0
              fprintf('*  N/A                      *\n');
          end          
          fprintf('*****************************\n');
          fprintf('*DYNAMIC                    *\n');
          for i=1:numel(obj.dynamic_names)
              fprintf('* %-26s*\n', obj.dynamic_names{i});
          end
          if numel(obj.parameter_names) == 0
              fprintf('*  N/A                      *\n');
          end
          fprintf('*****************************\n');
          fprintf('*METHODS                    *\n');
          for i=1:numel(obj.entry_names)
              fprintf('* %04x %-22s*\n', obj.entry_points(i), obj.entry_names{i});
          end
          if numel(obj.entry_names) == 0
              fprintf('*  N/A                      *\n');
          end          
          fprintf('*****************************\n');
      end
   end    
    methods
        function obj = VMClass(name)
            obj.name = name;
            obj.entry_names = {};
            obj.entry_points = [];
            obj.dynamic_names = {};
            obj.parameter_names = {};
        end
        
        function push_tag(obj, tag)
            obj.tags{end+1} = tag;
        end
        
        function entry = get_entry_by_id(obj, id)
            if id<1 || id>numel(obj.entry_points)
                error(sprintf('In class %s, invalid entry id: %d. Should be in range %d..%d.',obj.name, id, 1, numel(obj.entry_points)));
            end
            
            entry = obj.entry_points(id);
        end
        
        function id = get_parameter_id_by_name(obj, name)
            for i=1:numel(obj.parameter_names)
                if strcmp(obj.parameter_names{i}, name)
                    id = i;
                    return
                end
            end
            id = [];
        end
        
        function push_entry(obj, entry, entry_name)
            obj.entry_points(end+1) = entry;
            obj.entry_names{end+1} = char(entry_name);
        end
        
        function push_dynamic_name(obj, name)
            obj.dynamic_names{end+1} = char(name);
        end
        
        function push_parameter_name(obj, name)
            obj.parameter_names{end+1} = char(name);
        end
    end
end