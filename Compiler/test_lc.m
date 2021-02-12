buffer = fileread('LakeConstance.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
code = compiler.get_byte_code();
%Compiler.disassembler(code);
vm = VM(compiler.get_byte_code(), compiler.model);
data = vm.solve();
