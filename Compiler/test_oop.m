buffer = fileread('oop1.model');
%buffer = 'guild = new Guild { alpha=1; B=2; };';

compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
xxx
Compiler.disassembler(compiler.get_byte_code());
xxx
vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.solve();



