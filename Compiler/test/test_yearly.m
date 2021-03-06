buffer = Buffer(fileread('yearly.model'));
tokenizer = Tokenizer(buffer);
compiler = Compiler(Parser(tokenizer));
compiler.model.repr()
compiler.compile();
compiler.disassembler(compiler.get_byte_code());

vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.compare_solve();
