%buffer = fileread('producer_consumer_deploy.model');
buffer = fileread('simple_link.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.model.repr()
compiler.compile();
compiler.disassembler(compiler.get_byte_code());
vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.compare_solve();

