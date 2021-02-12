buffer = fileread('node_deploy.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
compiler.model.repr()
Compiler.disassembler(compiler.get_byte_code());

vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.compare_solve();



