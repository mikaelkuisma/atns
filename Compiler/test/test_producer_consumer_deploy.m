buffer = fileread('producer_consumer_deploy.model');
compiler = Compiler(Parser(Tokenizer(Buffer(buffer))));
compiler.model.repr()

compiler.compile();


compiler.disassembler(compiler.get_byte_code());

vm = VM(compiler.get_byte_code(), compiler.model);
data2 = vm.compare_solve().get_struct();

%buffer = fileread('producer_consumer_deploy.model');
t=0;
%  tag Alg1 = new { B=2000; igr = 1; s=0.2; };
%  tag Alg2 = new { B=3000; igr = 1.2; s=0.2; };
%    tag Con1 = new { B=1000; mbr=0.4; };
%  new <Con1, Alg1, Alg1> { e=0.5; q=1.2; B0=1000; d=1; };
%  new <Con1, Alg2, Alg1> { e=0.5; q=1.2; B0=1000; d=1; };
%gamma1 = 0.7;
%gamma2 = 0.5;
%gamma3 = 0.03;
B = [ 2000 3000 1000 ];
B0=1000;
fun = @(t,B) [ 1.0*(1-0.2)*(1-(2*B(1)+B(2))/5400)*B(1)-0.4*B(1)^1.2/(B(1)^1.2+B(2)^1.2+B0^1.2)*B(3)/0.5 1.2*(1-0.2)*(1-(B(1)+2*B(2))/5400)*B(2)-0.4*B(2)^1.2/(B(1)^1.2+B(2)^1.2+B0^1.2)*B(3)/0.5 -0.4*0.4*B(3)+0.4*(B(1)^1.2 + B(2)^1.2)/(B(1)^1.2+B(2)^1.2+B0^1.2)*B(3) ]';
hold on

t = (0:59);
[t,y] = ode45(fun, t, B',odeset('RelTol',1e-10,'AbsTol',1e-10));
hold off
plot(t, y,'ko');
hold on
plot(data2{1}.data{1}.x, data2{1}.data{1}.y,'rx');
plot(data2{2}.data{1}.x, data2{2}.data{1}.y,'rx');
plot(data2{2}.data{2}.x, data2{2}.data{2}.y,'rx');
assert(max(abs(data2{1}.data{1}.y'-y(:,3)))<2);
assert(max(abs(data2{2}.data{1}.y'-y(:,1)))<2);
assert(max(abs(data2{2}.data{2}.y'-y(:,2)))<2);