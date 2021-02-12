classdef session < handle & matlab.mixin.CustomDisplay
    properties
        % Path to session folder
        spath
        
        % The source file, which is monitored by session, and recompiled
        % upon update
        linked_source
        
        % Source file name (without paths, at the session folder)
        sourcefilename
        
        % Parser object
        parser
        
        % Compiler object
        compiler
        
        % Bytecode array (uint8)
        bytecode
        
        % virtual machine object
        vm
        
        % Host name of execution server
        hostname
        
        % results
        results
        
        selectedrun
        
        source_up_to_date % Is the source file at session directory up to date with its source file
        bytecode_up_to_date % Is bytecode variable up to date with the source file 
        results_up_to_date % Are the results up to date with the byte code
    end
    

   methods (Access = protected)
      function displayScalarObject(obj)
         % Implement the custom display for scalar obj
         if isempty(obj.linked_source)
            fprintf('No source file. Write\n    %s.source(''mysource.model'');\nto add a source file.\n\n', inputname(1));
            return
         end
         fprintf('Source file: %s\n', obj.linked_source);
         if isempty(obj.results)
             fprintf('\nWrite\n    %s.run(''myRun'');\nto run the model.\n\n', inputname(1));
         end
         runtxt = '';
         for rundir = dir(fullfile(obj.spath,'run*'))
             rname = rundir.name(5:end);
             runtxt = [ runtxt '    * ' sprintf('%-15s', rname) 'Created:' rundir.date ];
             if strcmp(obj.selectedrun, rname)
                 runtxt = [ runtxt ' SELECTED' ];
             end
             runtxt = [ runtxt '\n'];
         end
         if ~isempty(runtxt)
             runtxt = [ 'Stored results by id:\n' runtxt ];
         end
         fprintf(runtxt);
      end       
      
    end    
    
    methods
        function obj = session(spath)
            if isempty(spath)
                error('Valid directory name expected.');
            end
            validname = isstrprop(spath,'alphanum');
            if ~validname
                error('Session name must be alphanumeric only a..z, A..Z, 0..9');
            end
            if ~exist(spath, 'dir')
                disp(sprintf('Creating directory %s for session data. Do not edit it directly.', spath));
                mkdir(spath);
            end
            obj.spath = spath;
            obj.source_up_to_date = 0;
            obj.bytecode_up_to_date = 0;
            obj.results_up_to_date = 0;
        end
        
        function server(obj, hostname)
            obj.hostname = hostname;
        end
        
        function add(obj, element)
            if isa(element,'ATNResult')
                obj.results = [ obj.results command ];
            end
        end
        
        function sha256 = hash(obj, filename)
            sha256hasher = System.Security.Cryptography.SHA256Managed;
            sha256 = uint8(sha256hasher.ComputeHash(uint8(fileread(filename))));
        end
        
        function invalidate_results(obj)
            obj.results_up_to_date = 0;
        end
        
        function invalidate_bytecode(obj)
            obj.bytecode_up_to_date = 0;
            obj.invalidate_results();
        end
        
        function invalidate_source(obj)
            obj.source_up_to_date = 0;
            obj.invalidate_bytecode();
        end
        
        % Set the main model source code file to be used
        function source(obj, filename)
            obj.linked_source = filename;
            obj.invalidate_source();
            obj.update();
        end
        
        function filename = wpath(obj, name)
            filename = fullfile(obj.spath, name);
        end
        
        function create_binary_file(obj, fname, data)
            fullname = obj.wpath(fname);
            fid = fopen(fullname,'wb');
            assert(isa(data,'uint8'));
            fwrite(fid, data);
            fclose(fid);
            disp(sprintf('Written %d bytes to %s.', numel(data), fullname));
        end
        
        function update(obj)
            if ~obj.source_up_to_date
                if ~isempty(obj.sourcefilename) && ~strcmp(obj.sourcefilename, obj.linked_source)
                    warning(sprintf('Discarding old source file %s', obj.sourcefilename));
                end
                [fPath, fName, fExt] = fileparts(obj.linked_source);
                if ~strcmp(fExt,'.model')
                    error('.model file expected.');
                end

                source = obj.linked_source;

                dest = obj.wpath([fName fExt]);
                disp(sprintf('Copying file %s to %s.', source, dest));
            
                [success, msg, msgid] = copyfile(source, dest);
                if ~success
                    error(sprintf('Error copying source file. %s', msg));
                end
                obj.sourcefilename = [ fName fExt ];
                disp(sprintf('Current source file is now: %s', obj.sourcefilename));
                
                % Source is now copied, invalidate bytecode (and results
                % subsequently)
                obj.source_up_to_date = 1;
                obj.invalidate_bytecode();
            else
                disp(sprintf('Source file %s is up to date.', obj.sourcefilename));
            end
            % make sure compile is up to date
            if ~obj.bytecode_up_to_date
                disp(sprintf('Reading source %s...', obj.sourcefilename));
                buffer = fileread(obj.wpath(obj.sourcefilename));
                disp('Parsing...');
                obj.parser = Parser(Tokenizer(Buffer(buffer)));
                disp('Compiling...');
                obj.compiler = Compiler(obj.parser);
                obj.compiler.compile();
                obj.bytecode = obj.compiler.get_byte_code();
                obj.create_binary_file('main.code', obj.bytecode);
                obj.bytecode_up_to_date = 1;      
                obj.invalidate_results();
            end
        end
        
        function run(obj, name)
            obj.update();
            runpath = obj.wpath(['run_' name]);
            if ~exist(runpath, 'dir')
                mkdir(runpath);
            end            
            obj.selectedrun = name;
            disp(sprintf('Running at directory %s.', runpath));
            obj.vm = VM(obj.compiler.get_byte_code(), obj.compiler.model);
            results = obj.vm.solve();
            resultfile = fullfile(runpath, 'results.mat');
            save(resultfile,'results');
            disp(sprintf('Stored results to %s.', resultfile));
        end
        
    end
end