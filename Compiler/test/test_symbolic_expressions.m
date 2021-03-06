buffers = { ...
'a;', ... % 3
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
answers = [ 3 12 28 59049 -7 -6 3 15   12.823480217933577 -59036      7.625597484987000e+12
];

results = [];
namespace.a = 3;
namespace.b = 10;
namespace.ab13 = 13;

for i=1:numel(answers) % numel(buffers)
parser = Parser(Tokenizer(Buffer(buffers{i})));
results(i) = parser.parse_EXPRESSION().evaluate(namespace);
end

assert(all(abs(answers-results)<1e-10));
