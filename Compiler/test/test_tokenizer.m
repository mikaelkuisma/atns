lines = { ...
'', ...
'obj Guild {',...
'intermediate A 1+5*3/(3+5);',...
'intermediate B 5+5-3/(3*(2/3)+(2)+5);',...
'};', ...
'', ...
'obj Guild2 { ', ...
'', ...
'};',...
' '};
buffer = sprintf('%s\n', lines{:});
tokenizer = Tokenizer(Buffer(buffer));

token_types = [2 2 4 2 2 1 4 1 4 1 4 4 1 4 1 4 4 2 2 1 4 1 4 1 4 4 1 4 4 1 4 1 4 4 4 1 4 4 1 4 4 4 4 2 2 4 4 4];
assert(all(tokenizer.token_types == token_types));
token_datas = [ {'obj'}    {'Guild'}    {'{'}    {'intermediate'}    {'A'}    {[1]}    {'+'}    {[5]}    {'*'}   ...
                {[3]}    {'/'}    {'('}    {[3]}    {'+'}    {[5]}    {')'}    {';'}  {'intermediate'}    {'B'}  ...
  {[5]}    {'+'}    {[5]}    {'-'}    {[3]}    {'/'}    {'('}    {[3]}    {'*'}    {'('}    {[2]}  ... 
  {'/'}    {[3]}    {')'}    {'+'}    {'('}    {[2]}    {')'}    {'+'}    {[5]}    {')'}    {';'}  ...
  {'}'}    {';'}    {'obj'}    {'Guild2'}    {'{'}    {'}'}    {';'} ];
for i=1:numel(token_datas)
   assert(all(tokenizer.token_datas{i} == token_datas{i}));
end
