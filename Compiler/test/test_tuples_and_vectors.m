%buffer = 'parameter alpha=1.1;';
%buffer = fileread('vectors.model');
buffer = 'parameter A = [1,1,2];parameter B = [1.1,2.2,3.3];parameter C = A*B;parameter D = 2;';
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.compile();
Compiler.disassembler(compiler.get_byte_code());
vm = VM(compiler.get_byte_code(), compiler.model);
vm.compare_solve();
assert(all(vm.module_instance.parameter{1}.*vm.module_instance.parameter{2}==vm.module_instance.parameter{3}))

