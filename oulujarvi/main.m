
migration('oulujarvi_newsimp_korjattu_t.mat', 'new_simplified_oulujarvi.generated_model','modelfile','atn_with_fishing.model');
results_fast = atnsf('fast_new_runoulujarvi.model',1,'new');
dsaad

migration('5pros_oulujarvi_old_period_simplified_korjattu_t.mat', 'old_simplified_oulujarvi.generated_model','modelfile','atn_with_fishing.model');
results1 = atnsf('fast_old_runoulujarvi.model',1,'old');
dsa


if 0
load('oulujarvi_newsimp_korjattu_t.mat');
for i=1:numel(Data.Guilds)
  dnr(i) = ~startsWith(Data.Guilds(i).label,'Ppe');
end
Data.B0 = Data.B0(dnr,dnr);
Data.d = Data.d(dnr,dnr);
Data.y = Data.y(dnr,dnr);
Data.q = Data.q(dnr,dnr);
Data.e = Data.e(dnr,dnr);
Data.adjacencyMatrix = Data.adjacencyMatrix(dnr,dnr);
Data.Guilds = Data.Guilds(dnr);
save('oulujarvi_newsimp_korjattu_t_no_Ppe.mat','Data');
end

if 1
migration('5pros_oulujarvi_old_period_simplified_korjattu_t.mat', 'old_simplified_oulujarvi.generated_model','modelfile','atn_with_fishing.model');
results1 = atnsf('old_runoulujarvi.model',1);

migration('oulujarvi_newsimp_korjattu_t.mat', 'new_simplified_oulujarvi.generated_model','modelfile','atn_with_fishing.model');
results2 = atnsf('new_runoulujarvi.model',1);

migration('oulujarvi_newsimp_korjattu_t_no_Ppe.mat', 'new_simplified_oulujarvi_no_Ppe.generated_model','modelfile','atn_with_fishing.model');
results3 = atnsf('new_no_Ppe_runoulujarvi.model',1);



end

results1.structured_plot_all_guilds('r',1, [ 50 400 ]);
results2.structured_plot_all_guilds('b',0, [ 50 400 ]);
results3.structured_plot_all_guilds('k--',0, [ 50 400 ]);

% 

%clf
%semilogy(results.Bminor(1:20,2),'r');
%hold on
%semilogy(Results.allbiomasses(1:20,2),'b');
%load('..\Compiler\oulujarvi_old_code.mat');
%clf
%plot(results1.Bminor(1:20,2)-Results.allbiomasses(1:20,2),'r');
%hold on
%semilogy(Results.allbiomasses(1:20,2),'b');
%legend({'new','old'});
% Kalastussaaliit