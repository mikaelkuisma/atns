fid = fopen('temp.txt','wt');

for i = 1:length(Data.Guilds)
    G = Data.Guilds(i);
    fprintf(fid,'Nodes[%i] = {\n',i-1);
    fprintf(fid,'\tlabel: ''%s'',\n',G.label);
    fprintf(fid,'\tname: ''%s'',\n',G.name);
    fprintf(fid,'\ttype: ''%s'',\n',G.type);
    if isempty(G.igr)
        str = 'null';
    else
        str = num2str(G.igr);
    end
    fprintf(fid,'\tr: %s,\n',str);
    if isempty(G.mbr)
        str = 'null';
    else
        str = num2str(G.mbr);
    end
    fprintf(fid,'\tx: %s,\n',str);
    if isempty(G.avgl)
        str = 'null';
    else
        str = num2str(G.avgl);
    end
    fprintf(fid,'\tavgl: %s,\n',str);
    if isempty(G.lw_a)
        str = 'null';
    else
        str = num2str(G.lw_a);
    end
    fprintf(fid,'\tlw_a: %s,\n',str);
    if isempty(G.lw_b)
        str = 'null';
    else
        str = num2str(G.lw_b);
    end
    fprintf(fid,'\tlw_b: %s,\n',str);
    if isempty(G.binit)
        str = 'null';
    else
        str = num2str(G.binit);
    end
    fprintf(fid,'\tbinit: %s,\n',str);
    if isempty(G.age)
        str = 'null';
    else
        str = num2str(G.age);
    end
    fprintf(fid,'\tage: %s,\n',str);
    if isempty(G.f_m)
        str = 'null';
    else
        str = num2str(G.f_m);
    end
    fprintf(fid,'\tf_m: %s,\n',str);
    if isempty(G.c)
        str = 'null';
    else
        str = num2str(G.c);
    end
    fprintf(fid,'\tc: %s,\n',str);
    if isempty(G.s)
        str = 'null';
    else
        str = num2str(G.s);
    end
    fprintf(fid,'\ts: %s,\n',str);
    if isempty(G.diss_rate)
        str = 'null';
    else
        str = num2str(G.diss_rate);
    end
    fprintf(fid,'\tdiss_rate: %s,\n',str);
    if isempty(G.hatchery)
        str = 'null';
    else
        str = num2str(G.hatchery);
    end
    fprintf(fid,'\thatchery: %s,\n',str);
    if isempty(G.f_a)
        str = 'null';
    else
        str = num2str(G.f_a);
    end
    fprintf(fid,'\tf_a: %s,\n',str);
    if isempty(G.invest)
        str = 'null';
    else
        str = num2str(G.invest);
    end
    fprintf(fid,'\tinvest: %s,\n',str);
    if isempty(G.catchable)
        str = 'null';
    else
        str = num2str(G.catchable);
    end
    fprintf(fid,'\tcatchable: %s,\n',str);
    if isempty(G.Pmat)
        str = 'null';
    else
        str = num2str(G.Pmat);
    end
    fprintf(fid,'\tPmat: %s,\n',str);
    fprintf(fid,'};\n');
end