function varargout = resolve_compulsory_and_optional_parameters(...
    parameters, caller, ...
   compulsory_names, optional_names, optional_values)

  par = struct(parameters{:});
  N_compulsory = numel(compulsory_names);
  for i=1:N_compulsory
      if ~isfield(par, compulsory_names{i})
          generate_error('Compulsory parameter missing', ...
              [ compulsory_names ], par, caller);
      end
      if numel(par) > 1 && ischar(par(1).(compulsory_names{i}))
          str_cell_array = {};
          for k=1:numel(par)
              str_cell_array{k} = par(k).(compulsory_names{i});
          end
          varargout{i} = str_cell_array;
      else
          varargout{i} = par.(compulsory_names{i});
      end
  end
  found = N_compulsory;
  
  for i=1:numel(optional_names)
      if isfield(par, optional_names{i})
        varargout{N_compulsory+i} = par.(optional_names{i});
        found = found+1;
      else
        varargout{N_compulsory+i} = optional_values{i};
      end
  end
  if found ~= numel(fieldnames(par))
      generate_error('Unexpected parameters.', [ compulsory_names optional_names], par, caller); 
  end
end

function generate_error(errmsg, parameter_names, par, caller)
  errmsg = [ errmsg newline];
  errmsg = [ errmsg 'Expected: ' newline ];
  errmsg = [ errmsg sprintf('  %s\n', parameter_names{:}) ];
  errmsg = [ errmsg newline 'Got: ' newline ];
  fnames = fieldnames(par);
  errmsg = [ errmsg sprintf('  %s\n', fnames{:}) ];
  if numel(fnames)==0
      errmsg = [ errmsg 'None.' ];
  end
  errmsg = [ errmsg newline 'Usage:' newline];
  errmsg = [ errmsg caller '('];
  for i=1:numel(parameter_names)
      errmsg = [ errmsg '''' parameter_names{i} ''', value' ];
      if i ~= numel(parameter_names)
          errmsg = [ errmsg ',...' newline];
      end
  end
  errmsg  = [ errmsg ');'];
  error(errmsg);
end