buffer = 'b=[[1,2], [3,4]]; a=@PRINT(b);';
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
Compiler.disassembler(compiler.get_byte_code());
xxx
vm = VM(compiler.get_byte_code(), compiler.model);
vm.solve();
