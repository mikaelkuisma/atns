buffer = fileread('structured.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
Compiler.disassembler(compiler.get_byte_code());

vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.compare_solve();
