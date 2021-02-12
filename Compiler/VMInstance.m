classdef VMInstance < handle & matlab.mixin.CustomDisplay
    properties
        vmclass
        classname
        dynamic
        parameter
        gradient
    end
   methods (Access = protected)
      function displayScalarObject(obj)
          fprintf('*****************************\n');
          fprintf('* %-26s*\n', obj.vmclass.name);
          fprintf('*****************************\n');
          fprintf('*PARAMETERS                 *\n');
          for i=1:numel(obj.vmclass.parameter_names)
              if numel(obj.parameter)>=i
                  param = obj.parameter{i};
              else
                  param = NaN;
              end
              fprintf('* %-15s %-10.f*\n', obj.vmclass.parameter_names{i}, param);
              
          end
          if numel(obj.vmclass.parameter_names) == 0
              fprintf('*  N/A                      *\n');
          end          
          fprintf('*****************************\n');
          fprintf('*DYNAMIC                    *\n');
          for i=1:numel(obj.vmclass.dynamic_names)
              if numel(obj.dynamic)>=i
                  param = obj.dynamic{i};
              else
                  param = NaN;
              end

              fprintf('* %-15s %-10f*\n', obj.vmclass.dynamic_names{i}, param);
          end
          if numel(obj.vmclass.parameter_names) == 0
              fprintf('*  N/A                      *\n');
          end
          fprintf('*****************************\n');

      end 
    end
    methods
        function obj = VMInstance(vmclass)
            obj.vmclass = vmclass;
            obj.classname = vmclass.name;
            obj.dynamic = {};
            obj.parameter = {};
            obj.gradient = {};
        end
        
        function entry = get_entry_by_id(obj, id)
            entry = obj.vmclass.get_entry_by_id(id);
        end
        
        function data = get_deploy_struct(obj)
            data.title = char(obj.classname);
            fields = {};
            for i=1:numel(obj.vmclass.parameter_names)
              field.type = 'parameter';
              field.name = char(obj.vmclass.parameter_names{i});
              if numel(obj.parameter)>=i
                  param = obj.parameter{i};
              else
                  param = NaN;
              end
              field.value = param;
              fields{end+1} = field;
            end
            for i=1:numel(obj.vmclass.dynamic_names)
              field.type = 'dynamic';
              field.name = char(obj.vmclass.dynamic_names{i});
              if numel(obj.parameter)>=i
                  param = obj.dynamic{i};
              else
                  param = NaN;
              end
              field.value = param;
              fields{end+1} = field;
            end
            
            data.fields = fields;
        end
        
        function value = get_parameter_by_name(obj, name)
            id = obj.vmclass.get_parameter_id_by_name(name);
            if isempty(id)
                value = [];
                return
            end
            value = obj.parameter{id};
        end

    end
end