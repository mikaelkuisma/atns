classdef Buffer < handle
    properties
        filename
        
        % The buffer data is stored here
        buffer
        
        % Pointer to current (unread) position of the buffer
        ptr
        
        % There are methods push_ptr() and () which push and pop
        % buffer pointers to this stack. This is required for prereads.
        ptr_stack
        line_stack
        
        lines 
        
        % End pointer (exclusive) for the buffer. numel(buffer)+1.
        end_ptr
        
        % The current line number for error messages
        linenumber
        
        % The start offset of current line for error messages
        linestart      
    end
    methods (Access=public)
        function obj = Buffer(filename)
            if isfile(filename)
                fprintf('Reading file %s.\n', filename);
                obj.filename =filename;
                obj.buffer = fileread(filename);
            else
                obj.filename = 'N/A';
                obj.buffer = filename;
            end
            obj.ptr = 1;
            obj.ptr_stack = [];
            obj.line_stack = [];
            obj.end_ptr = numel(obj.buffer)+1;
            obj.linenumber = 1;
            obj.linestart = 1;            
            obj.lines = {};
            obj.lines{obj.linenumber} = obj.get_current_line();
        end
        
        function pos = get_position(obj)
            pos = [ obj.linenumber obj.ptr-obj.linestart ];
        end
        
        function push_ptr(obj)
            obj.ptr_stack(end+1) = obj.ptr;
            obj.line_stack(end+1) = obj.linestart;
        end
        
        function pop_ptr(obj)
            obj.ptr = obj.ptr_stack(end);
            obj.linestart = obj.line_stack(end);
            obj.ptr_stack = obj.ptr_stack(1:end-1);
            obj.line_stack = obj.linestart(1:end-1);
        end
        
        function stash_ptr(obj)
            obj.ptr_stack = obj.ptr_stack(1:end-1);
            obj.line_stack = obj.linestart(1:end-1);
        end
        
        function line = get_current_line(obj)
            lineend = obj.linestart;
            while 1
                if (lineend >= obj.end_ptr)
                    break
                end
                if (obj.buffer(lineend)==10)
                    break
                end
                lineend=lineend+1;
            end
            line = reshape(obj.buffer(obj.linestart:lineend-1),1,[]);
        end
        
        function error(obj, position, msg, filename)
            %line = obj.get_current_line();
            %obj.linenumber
            %errorpos = obj.ptr-obj.linestart;
            %if (errorpos == 0)
            %    errorpos=1;
            %end
            if isempty(position)
                position = [ -1 -1];
            end
            errorpointer = [ repelem(' ', max(0,position(2))) '^'];
            %error(sprintf('Error in line %d col %d:\n%s\n%s\n%s', obj.linenumber, max(1,errorpos), msg, line, errorpointer));
            if nargin < 4 || strcmp(filename,'N/A')
                if position(1) > numel(obj.lines) || position(1) <= 0
                    line = 'end of file';
                else
                    line=obj.lines{position(1)};
                end
            else
                buffer = Buffer(filename);
                while ~buffer.is_eof()
                    buffer.get();
                end
                line = buffer.lines{position(1)};
            end
            fprintf('%s', msg);
            error(sprintf('Error in file %s line %d col %d:\n%s\n%s\n%s', filename, position(1), position(2), msg, line, errorpointer));
        end
        
        function str = read(obj)
            str = []; % TODO: buffer this also
            while ~obj.is_eof()
                str = [ str obj.get() ];
            end
            if numel(str)>0 && str(end)==0
                str = str(1:end-1);
            end
            if numel(str) == 0
                str = '';
            end
        end
        
        function c = get(obj)
            comment_lines_ended = 0;
            
            while ~comment_lines_ended
                % By default, this while loop will exit                
                comment_lines_ended = 1; 
                if obj.is_eof()
                    c=char(0);
                    return
                end

                % Read the actual character
                c = obj.buffer(obj.ptr);
                
                if (obj.ptr>1) 
                    if c == 10 
                        % The previous read was a line change. Now reading a 
                        % character from new line-->update the line number 
                        % information.
                        obj.linenumber = obj.linenumber + 1;
                        obj.linestart = obj.ptr + 1;
                        obj.lines{obj.linenumber} = obj.get_current_line();
                    end
                end

                % Increase the buffer pointer
                obj.ptr = obj.ptr + 1;

                
                % Check if a comment begins, i.e. is the next char also '/'. 
                % There is also a check, if the file ends with a single '/'
                % so we do not overflow the buffer.
                if c == '/' && obj.ptr <= numel(obj.buffer) && obj.buffer(obj.ptr) == '/'
                    comment_ended = 0;
                    % Read the rest of the comment line
                    % This will also read out the encountered '/'
                    while ~comment_ended
                        % Read a character from the comment line
                        c = obj.buffer(obj.ptr); 
                        
                        % Increase the buffer pointer
                        obj.ptr = obj.ptr + 1;
                        
                        % If end of line, or end of file reached, we are
                        % finished with the comment line...
                        if c == 10 || obj.is_eof()
                            comment_ended = 1;
                            obj.linenumber = obj.linenumber + 1;
                            obj.linestart = obj.ptr + 1;
                            obj.lines{obj.linenumber} = obj.get_current_line();
                        end
                    end
                        
                    % However, we necessarily do not know, if the next line
                    % also would start with a comment. Therefore, we have
                    % to loop back and read a new character and repeat the 
                    % procedure. 
                    comment_lines_ended = 0;
                        
                end
            end
        end
        
        function c = peek(obj)
            if obj.is_eof()
                c=char(0);
                return
            end
            ptr_stored = obj.ptr;
            linenumber = obj.linenumber;
            linestart = obj.linestart;
            lines = obj.lines;
            c = obj.get();
            obj.ptr = ptr_stored;
            obj.linenumber = linenumber;
            obj.linestart = linestart;
            obj.lines = lines;
        end
        
        function eof = is_eof(obj)
            eof = (obj.ptr >= obj.end_ptr);
        end
    end

end