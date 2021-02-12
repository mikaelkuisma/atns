buffer = fileread('LC_producer_consumer_backup.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.model.repr()
compiler.compile();
compiler.disassembler(compiler.get_byte_code());
vm = VM(compiler.get_byte_code(), compiler.model);
[x,data2] = vm.compare_solve().get_daily_data();
