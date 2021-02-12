buffers = { ...
'b=3;a=2;c=a*b;', ... % 3
'4*a;',...% 12
'3*a+2*b-1;', ... % 28 
'a^b;', ... % 2
'a-b;', ... % -7
'a+2-b-a+2;', ... % -6
'(a);', ... % 3
'a-(a-a)-a+(a+a+a)+a+(a);', ... % 15 
'a+b-a/(b*(a/3)+(b)^(a/b)+5);', ...
'ab13-a^b;', ...
'a^(a^a);' };
answers = [ 3 ];

results = [];
namespace = Namespace();

for i=1:numel(answers) % numel(buffers)
parser = Parser(Tokenizer(Buffer(buffers{i})));
statement = parser.require_STATEMENT();
results(i) = statement.evaluate(namespace);
end

assert(all(abs(answers-results)<1e-10));
