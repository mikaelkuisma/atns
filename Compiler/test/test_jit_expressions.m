% These do not work (Compiler does not compile orphan expressions because
% they have no effect. TODO: Code functions and return statements.
if 1
    buffers = { ...
'-3*2', ... % 6
'1/10+1',...
'13', ... % 13 
'1+1', ... % 2
'1-5', ... % -4
'1+2-5-2+2', ... % -2
'1-2+5-2+2', ... % 4
'(10)', ... % 10
'1-(-1-1)-1+(1+1+2)+5+(1)', ... %10 
'5+5-3/(3*(2/3)+(2)+5)', ...
'1+12/(1+2-2*(2/4-2*3))', ...
'2^3^4', ...
'2^(2^2)', ...
'2^(2+1)-3*(2^(1/6))^(1/3)' };
answers = [ -6 1.1 13 2 -4 -2 4 10 12 9.666666666666666 1.857142857142857 4096 16    4.882222321904470 ];
results = {};
for i=1:numel(answers) % numel(buffers)
compiler = Compiler(Parser(Tokenizer(Buffer(['@PRINT(' buffers{i} ');']))));
compiler.compile();
results{1,i} = buffers{i};
code = compiler.get_byte_code();
Compiler.disassembler(code);

vm = VM(code);
results{2,i} = vm.execute();

results{3,i} = answers(i);
%results{4,i} = abs(results{2,i}-results{3,i});
%results(i)= parser.require_STATEMENT().evaluate([]);
end
%cell2table(results', 'VariableNames',{'Expression','Calculated','Correct','abs diff.'})
%assert( all(cell2mat(results(4,:)) <1e-10));
%assert(all(abs(answers-results)<1e-13));
end