fid = fopen('snippets.txt');
f2 = fopen('snippets.js','w');
tline = fgetl(fid);
while ischar(tline)
    fprintf(f2, '%s\\n\\\n', tline);
    disp(tline)
    tline = fgetl(fid);
end
fclose(fid);
fclose(f2);