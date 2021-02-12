function compileserver
bytecode = [];
compiler = [];
isDEBUG=1;
port = 5566;
defaultoptions=struct('www_folder','www','temp_folder','www/temp','verbose',true,'defaultfile','/index.html','mtime1',0.1,'mtime2',0.3);
if(~exist('config','var')), config=defaultoptions;
else
    tags = fieldnames(defaultoptions);
    for i=1:length(tags),
        if(~isfield(config,tags{i})), config.(tags{i})=defaultoptions.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(config))),
        warning('image_registration:unknownoption','unknown options found');
    end
end

% Open a TCP Server Port
TCP=JavaTcpServer('initialize',[],port,config);

if(config.verbose)
    disp(['Webserver Available on http://localhost:' num2str(port) '/']);
end

while(true)
    % Wait for connections of browsers
    disp('Ready');
    TCP=JavaTcpServer('accept',TCP,[],config);
    disp('Connection Accepted');
    % If socket is -1, the user has close the "Close Window"
    if(TCP.socket==-1), break, end

    % Read the data form the browser as an byte array of type int8

    [TCP,requestdata]=JavaTcpServer('read',TCP,[],config);
    char(requestdata)
    if(isempty(requestdata))
        continue;
    end

    if(config.verbose), disp(char(requestdata(1:min(20,end)))); end

    % Convert the Header text to a struct
    request = text2header(requestdata,config);
%    if(config.verbose), disp(request); end

    request_type = '';
  % The filename asked by the browser
    if(isfield(request,'Get'))
        filename=request.Get.Filename;
        request_type='GET';
    elseif(isfield(request,'Post'))
        request_type='POST';
        filename=request.Post.Filename;
    elseif(isfield(request,'Options'))
        request_type = 'OPTIONS';
    else
        warning('Unknown Type of Request');
        continue
    end
    
    try
        if strcmp(request_type,'OPTIONS')
            html = '';
            %header=make_html_http_header(html,1);
            %header = struct();
            %header.CORS = true;
            %response=header2text(header);
            %header
            %response
            text = {'HTTP/1.1 204 No Content',
'Access-Control-Allow-Origin: *',
'Access-Control-Allow-Methods: GET,HEAD,PUT,PATCH,POST,DELETE',
'Vary: Access-Control-Request-Headers',
'Access-Control-Allow-Headers: Content-Type, Accept',
'Content-Length: 0',
'Date: Fri, 05 Apr 2019 11:41:08 GMT',
'Connection: close',
''}
            response = sprintf('%s\n', text{:});
        elseif strcmp(request_type,'POST')
        if strcmp(filename,'/compile.m')
            buffer = request.Content.editorText;
            html = [];
            try
               compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
               compiler.compile();
               bytecode = compiler.get_byte_code();
               %Compiler.disassembler(bytecode);
            catch e
                html = e.message;
                compiler = [];
            end
            if isempty(html) % Succesfull
                html = sprintf('Compiled source succesfully to %d bytes of bytecode.',numel(bytecode));
            end
            header=make_html_http_header(html,1);
            response=header2text(header);
        elseif strcmp(filename,'/deployinfo.m')
            if ~isempty(vm)
                html = jsonencode(vm.get_deploy_struct())
            else
                html = '';
            end
            header=make_html_http_header(html,1);
            response=header2text(header);
        elseif strcmp(filename,'/deploy.m')
            %buffer = request.Content.deploytext;
            if 0
            fid = fopen('web_compiled.byte','wb');
            fwrite(fid, bytecode);
            fclose(fid);
            tic
            [status, cmdout] = system('C:\Users\35840\source\repos\JITCompiler\Debug\JITCompiler.exe web_compiled.byte web_compiled.out');
            toc
            data.cmdout = cmdout;
            resultarray=load('web_compiled.out');
            data = {};
            for d = 1:(size(resultarray,2)-1)
               plotdata.x = resultarray(:,1);
               plotdata.y = resultarray(:,d+1);
               data.plotdata{d} = plotdata;
            end
            data
            html=jsonencode(data);
            end
            try
               if ~isempty(compiler)
               vm = VM(bytecode, compiler.model);
               data = vm.jit_solve();
               %data
               html = data.asjson();
               html
               else
                   html='';
               end
               %compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
               %compiler.compile();
            catch e
                html = e.message;
                rethrow(e);
            end

            header=make_html_http_header(html,1);
            response=header2text(header);
        else
            error('Unkown POST');
        end
    end

 if strcmp(request_type, 'GET')
    % If no filename, use default
  if(strcmp(filename,'/')), filename=config.defaultfile; end

  % Make the full filename inluding path
  fullfilename=[config.www_folder filename];
  [pathstr,name,ext] = fileparts(fullfilename);

  %if strcmp(fullfilename,'www/index.html')
%            html = program.get_html();
%            header=make_html_http_header(html,1);
%            response=header2text(header);
   if strcmp(fullfilename,'www/properties.json')
     html = program.get_treeview_json();
     header=make_html_http_header(html,1);
      response=header2text(header);
  else
  found = 0;
  % Check if file asked by the browser can be opened
  fid = fopen(fullfilename, 'r');
  if(fid<0)
      filename='/404.html'; found=false;
      fullfilename=[config.www_folder filename]; 
  else
      found=true; fclose(fid);
  end
    % Based on the extention asked, read a local file and parse it.
    % or execute matlab code, which generates the file
   switch(ext)
     case {'.jpg','.png','.gif','.ico'}
            fid = fopen(fullfilename, 'r');
            disp(fullfilename)
            html = fread(fid, inf, 'int8')';
            fclose(fid);
            header=make_image_http_header(html,found);
            response=header2text(header);
       case {'.css'}
            fid = fopen(fullfilename, 'r');
            disp(fullfilename)
            html = fread(fid, inf, 'int8')';
            fclose(fid);
            header=make_css_http_header(html,found);
            response=header2text(header);           
       otherwise
               fid = fopen(fullfilename, 'r');
               html = fread(fid, inf, 'int8')';
               fclose(fid);
               header=make_html_http_header(html,found);
               response=header2text(header);
   end
     end

  %      case {'.m'}
  %          addpath(pathstr)
  %          fhandle = str2func(name);
  %          try
  %          html=feval(fhandle,request,config);
  %          catch ME
  %              html=['<html><body><font color="#FF0000">Error in file : ' name ...
  %                  '.m</font><br><br><font color="#990000"> The file returned the following error: <br>' ...
  %                  ME.message '</font></body></html>'];
  %          end
  %          rmpath(pathstr)
  %          header=make_html_http_header(html,found);
  %          response=header2text(header);
  %      case {'.html','.htm'}
  %          fid = fopen(fullfilename, 'r');
  %          html = fread(fid, inf, 'int8')';
  %	  	fclose(fid);
  %          header=make_html_http_header(html,found);
  %          response=header2text(header);
  %          fid = fopen(fullfilename, 'r');
  %          html = fread(fid, inf, 'int8')';
  %          fclose(fid);
  %          header=make_bin_http_header(html,found);
  %          response=header2text(header);
  %  end

 end
 
%if(config.verbose), disp(char(response)); end
    catch e
        if isDEBUG 
            rethrow(e);
        else
            html = ['<pre>' getReport(e) '</pre>'];
            header=make_html_http_header(html,1);
            response=header2text(header);
        end
    end
    % Give the generated HTML or binary code back to the browser
    response
    html
    JavaTcpServer('write',TCP,int8(response),config);
    if strcmp(class(html),'string')
        html=char(html);
        html
    end
    disp('Writing');
    JavaTcpServer('write',TCP,int8(html),config);
    disp('Done');
end
JavaTcpServer('close',TCP);
