%buffer = fileread('producer_consumer_deploy.model');
t=0;
gamma1 = 0.7;
gamma2 = 0.5;
gamma3 = 0.03;
fun = @(t,B) [ B(1)-gamma1*B(1)*B(3) B(2)-gamma2*B(2)*B(3) -B(3)+gamma2*B(2)*B(3)+gamma1*B(1)*B(3)-gamma3*B(3)*B(4) -0.03*B(4)+gamma3*B(3)*B(4) ]';
buffer = fileread('lv_link.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.model.repr()

compiler.compile();

compiler.disassembler(compiler.get_byte_code());

vm = VM(compiler.get_byte_code(), compiler.model);
results = vm.jit_solve();
results.plot();
