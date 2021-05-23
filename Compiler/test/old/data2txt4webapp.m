fid = fopen('Example_ids.txt','wt');

for i = 1:length(Data.Guilds)
    G = Data.Guilds(i);
    fprintf(fid,'%s\n',G.label);
end

fclose(fid)

%%

fid = fopen('Example_links.txt','wt');

for i = 1:size(A,1)
    for j = 1:size(A,2)
        if j == size(A,2)
            fprintf(fid,'%i',A(i,j));
        else
            fprintf(fid,'%i,',A(i,j));
        end
    end
    fprintf(fid,'\n');
end

fclose(fid)