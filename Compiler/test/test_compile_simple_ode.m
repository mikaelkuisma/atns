buffer = fileread('LakeConstance.model');
buffer = buffer( buffer ~= '_' ); % Underscores are not allowed in variable names
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
code = compiler.get_byte_code()
%fid = fopen('C:\Users\35840\source\repos\ATNRunner\JITCompiler\LakeConstance.modelc','wb');
%fwrite(fid,code)
%fclose(fid);
size(code)
Compiler.disassembler(code);
vm = VM(code, compiler.model);
vm.solve([], 3);
