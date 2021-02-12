function model = migration(filename, target, varargin)
global fid
mfilename
[filepath,name,ext] = fileparts(mfilename('fullpath'))

mdef = fullfile(filepath,'LC.mdef')

lines = fileread(mdef)

fid = fopen(target,'w');
fprintf(fid, lines);
   %model = ATNModel();
   all = {};
   load(filename, 'Data');
   options = struct(varargin{:});
   if isfield(options, 'removebelow')
       removebelow = options.removebelow;
   else
       removebelow = 0;
   end
   if isfield(options, 'selectonly')
       selectonly = options.selectonly;
   else
       selectonly = '';
   end
   % Read original .mat data format
   if ~isfield(Data, 'communityMatrix')
       Data.communityMatrix = Data.B0 ~= 0;
   end
   this.communityMatrix = Data.communityMatrix;
   this.B0 = Data.B0;
   this.d = Data.d;
   this.y = Data.y;
   this.q = (Data.q>1)*1.0;
   
   this.K = Data.K;
   this.e = Data.e;
   this.Guilds = Data.Guilds;
         
   % Loop over different guild items and resolve Producer, Detritus,
   % Consumer and Fish types.
   producers = {};
   detritus = {};
   consumers = {};
   fishes = {};
   all = {};
   indices = [];
   nGuilds = prod(size(Data.Guilds));
   for i=1:nGuilds
       guild = Data.Guilds(i);
       label = guild.label;
       name = guild.name;
       binit = guild.binit;
       if numel(selectonly)==0 || strcmp(guild.type, selectonly)
          if strcmp(guild.type, 'Producer')
              s = guild.s;
              igr = guild.igr;
              producer = struct('label', label, 'name', name, 'binit', binit, 's', s, 'igr', igr);
              producer.index = i;
              all{end+1} = producer;
              producers{end+1} = producer;
              indices = [ indices i ];
          elseif strcmp(guild.type, 'Detritus')
              diss_rate = guild.diss_rate;
              detri = struct('label', label, 'name', name, 'binit', binit, 'dissrate', diss_rate);
              detritus{end+1} = detri;
              all = [ all detri ];
              indices = [ indices i ];
          elseif strcmp(guild.type, 'Consumer')
              mbr = guild.mbr;
              f_m = guild.f_m;
              f_a = guild.f_a;
              consumer = struct('label', label, 'name', name, 'binit', binit, 'mbr', mbr, 'f_m', f_m, 'f_a', f_a);
              consumer.index = i;
              if strcmp(label,'Bac')
                  disp('bac')
              end
              all = [ all consumer ];
              consumers = [consumers consumer];
              indices = [ indices i];
          elseif strcmp(guild.type, 'Fish')
              mbr = guild.mbr;
              f_m = guild.f_m;
              f_a = guild.f_a;
              avgl = guild.avgl;
              lw_a = guild.lw_a;
              lw_b = guild.lw_b;
              bodymass = guild.bodymass;
              age = guild.age;
              hatchery = guild.hatchery;     
              invest = guild.invest;
              catchable = guild.catchable;
              Pmat = guild.Pmat;
              fish = struct('label', label, 'name', name, 'binit', binit, 'mbr', mbr, 'f_m', f_m, 'f_a', f_a, ...
                             'avgl', avgl, 'lw_a', lw_a, 'lw_b', lw_b, 'age', age, 'hatchery', hatchery, ...
                             'invest', invest, 'catchable', catchable, 'Pmat', Pmat,'bodymass', bodymass);
              
              fishes{end+1} = fish;
              %consumers{end+1} = fish;
              indices = [ indices i];
              all{end+1} = fish;
              end
       end
   end
   
     if numel(detritus)>0
     push('deploy Detritus\n');
     push('{\n');
     for i=1:numel(detritus)
         push(['  tag ' detritus{i}.label ' = new { ']);
         push(['B = ' num2str(detritus{i}.binit) '; ']);
         push(' };\n');
     end
     push('};\n');
     end

     
     push('deploy Producer\n');
     push('{\n');
     push(['  K = ' num2str(Data.K.mean) ';\n']);
     push(['  intra = 2.0;\n']);
     push(['  inter = 1.0;\n']);
     for i=1:numel(producers)
         if producers{i}.binit>removebelow
         push(['  tag ' producers{i}.label ' = new { ']);
         push(['B = ' num2str(producers{i}.binit) '; ']);
         push(['s = ' num2str(producers{i}.s) '; ']);
         push(['igr = ' num2str(producers{i}.igr) '; ']);
         push(' };\n');
         end
     end
     push('};\n');
     
     push('deploy Consumer\n');
     push('{\n');
     for i=1:numel(consumers)
         if consumers{i}.binit>removebelow
         push([' tag ' consumers{i}.label ' = new { ']);
         push(['B = ' num2str(consumers{i}.binit) '; ']);
         push(['mbr = ' num2str(consumers{i}.mbr) '; ']);
         push(['fm = ' num2str(consumers{i}.f_m) '; ']);
         push(['fa = ' num2str(consumers{i}.f_a) '; ']);
         push(' };\n');
         end
     end
     push('};\n');

     %fish = struct('label', label, 'name', name, 'binit', binit, 'mbr', mbr, 'f_m', f_m, 'f_a', f_a, ...
     %                        'avgl', avgl, 'lw_a', lw_a, 'lw_b', lw_b, 'age', age, 'hatchery', hatchery, 'invest', invest, 'catchable', catchable, 'Pmat', Pmat);
     
     if numel(fishes)>0
     push('deploy Fish\n');
     push('{\n');
     namewonumber = {};
     for i=1:numel(fishes)
         namewonumber{end+1} = fishes{i}.label(isstrprop(fishes{i}.label,'alpha'));
         push(['  tag ' fishes{i}.label ' = new { ']);
         push(['B = ' num2str(fishes{i}.binit) '; ']);
         push(['mbr = ' num2str(fishes{i}.mbr) '; ']);
         push(['fm = ' num2str(fishes{i}.f_m) '; ']);
         push(['fa = ' num2str(fishes{i}.f_a) '; ']);
         push(['avgl = ' num2str(fishes{i}.avgl) '; ']);
         push(['lwa = ' num2str(fishes{i}.lw_a) '; ']);
         push(['lwb = ' num2str(fishes{i}.lw_b) '; ']);
         push(['age = ' num2str(fishes{i}.age) '; ']);
         push(['hatchery = ' num2str(fishes{i}.hatchery) '; ']);
         push(['invest = ' num2str(fishes{i}.invest) '; ']);
         push(['catchable = ' num2str(fishes{i}.catchable) '; ']);
         push(['Pmat = ' num2str(fishes{i}.Pmat) '; ']);
         push(['bodymass = ' num2str(fishes{i}.bodymass) '; ']);
         push('  };\n'); 
     end
     push('};\n');     
     end
     namewonumber = unique(namewonumber);
     maxage = zeros(numel(namewonumber),1);
     minage = 100*ones(numel(namewonumber),1);
     if numel(fishes)>0
     for i=1:numel(fishes)
        age = str2num(fishes{i}.label(isstrprop(fishes{i}.label,'digit')));
        for j=1:numel(namewonumber)
            if strcmp(namewonumber{j}, fishes{i}.label(isstrprop(fishes{i}.label,'alpha')))
                maxage(j) = max(age, maxage(j));
                minage(j) = min(age, minage(j));
            end
        end
     end
     end
     
     
     conn = full(this.B0>0);
     omega = conn ./ repmat(sum(conn,2), 1,size(conn,2));
     omega(find(isnan(omega)))=0;
     
     push('deploy Feeding\n');
     push('{\n');
     for id1 = indices
         if Data.Guilds(id1).binit <= removebelow
             continue
         end
         for id2 = indices
             if Data.Guilds(id2).binit <= removebelow
                 continue
             end
             if this.B0(id1,id2) == 0
                 continue
             end
         push(sprintf(['  new <%s,%s,%s> { '], Data.Guilds(id1).label, Data.Guilds(id2).label,'POC'));
         push(['B0 = ' num2str(this.B0(id1,id2)) '; ']);
         push(['q = '  num2str(this.q(id1,id2)) '; ']);
         push(['y = '  num2str(this.y(id1,id2)) '; ']);
         push(['d = '  num2str(this.d(id1,id2)) '; ']);
         push(['e = '  num2str(this.e(id1,id2)) '; ']);
         push(['w = '  num2str(omega(id1,id2)) '; ']);
         push(' }; \n');
             
         end
         end
     push('};');
     
push('deploy Dissolvation\n');
push('{\n');
push('  tag diss = new <POC, DOC, DOC> { rate = 0.1; };\n');
push('};\n\n');

push('deploy Aging\n');
push('{\n');
for j = 1:numel(namewonumber)
    for age=minage(j):maxage(j)-1
        push(sprintf(' new <%s%d, %s%d, POC> {};\n', namewonumber{j}, age, namewonumber{j}, age+1)); 
    end
end
push('};\n');
     
push('deploy Breeding\n');
push('{\n');
for j = 1:numel(namewonumber)
    for age=minage(j)+1:maxage(j)
        push(sprintf(' new <%s%d, %s%d, POC> {};\n', namewonumber{j}, minage(j), namewonumber{j}, age)); 
    end
end
push('};\n');
     
     fclose(fid);
     return
     %this.producers = producers;
     %this.detritus = detritus;
     %this.consumers = consumers;
     %this.fishes = fishes;
     %this.all = [ this.detritus this.producers this.consumers this.fishes ];
     %model.add(all);
     
     %model.add(ATNIntrinsicGrowthModel(producers, 'K',  Data.K.mean, ...
     %                                  'IntraSpeciesCompetitionCoefficient', 2.0, ...
     %                                  'InterSpeciesCompetitionCoefficient', 1.0));
     %model.add(ATNMetabolicRate(consumers));
     cM = full(this.communityMatrix(indices, indices));
     row = '%                 ';
     for i=1:size(cM,1)
         row = sprintf('%s%7s', row, all{i}.label);
     end
     disp(row)
     for i=1:size(cM,1)
         row = sprintf('func.diet(%7s, {', sprintf('''%s''', all(i).label));
         comma = '';
         for j=1:size(cM,1)
             
             if cM(i,j)==1
                 cell = sprintf('%s''%s''', comma, all(j).label);
                 comma = ',';
             else
                 cell='';
             end
             row = sprintf('%s%7s', row, cell);
         end
         row = [ row '});'];

         disp(row)
     end
     all_indices = [ all(:).index ];
     consumer_indices = [ consumers(:).index ];
     
     B0 = full(this.B0(consumer_indices, all_indices));
     d = full(this.d(consumer_indices, all_indices));
     y = full(this.y(consumer_indices, all_indices));
     q = full(this.q(consumer_indices, all_indices));
     e = full(this.e(consumer_indices, all_indices));
     matrices = [ ...
     outputInteractionMatrix('conn', conn, { consumers(:).label },{ all(:).label } ) ...
     outputInteractionMatrix('B0', B0, { consumers(:).label },{ all(:).label } ) ...
     outputInteractionMatrix('d', d, { consumers(:).label },{ all(:).label } ) ...
     outputInteractionMatrix('y', y, { consumers(:).label },{ all(:).label } ) ...
     outputInteractionMatrix('q', q, { consumers(:).label },{ all(:).label } ) ...
     outputInteractionMatrix('e', e, { consumers(:).label },{ all(:).label } ) ];
     disp(matrices);
     omega = conn ./ repmat(sum(conn,2), 1,size(conn,2));
     omega(find(isnan(omega)))=0;
     model.add(ATNFunctionalResponse(all, consumers, 'y',y, 'e',e, 'B0',B0, 'd',d, 'omega', omega));



     %model.del([ Per0 Per1 Per2 Per3 Per4]);
     
     %full(this.communityMatrix(indices, indices)) == full(this.B0(indices, indices))/1500
     %full(this.communityMatrix(indices,indices)) == full(this.e(indices, indices)>1)
     %subplot(2,1,1);
     %imagesc(this.communityMatrix(indices,indices));
     %subplot(2,1,2);
     %imagesc(this.e(indices, indices))
     %full(this.e(indices,indices)
end
function push(str)
global fid
fprintf(str);
fprintf(fid, str);
end