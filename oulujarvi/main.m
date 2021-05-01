migration('5pros_oulujarvi_old_period.mat', 'oulujarvi.generated_model','modelfile','atn_with_fishing.model');
tic
results1 = atnsf('runoulujarvi.model',1);
toc
clf
%semilogy(results.Bminor(1:20,2),'r');
%hold on
%semilogy(Results.allbiomasses(1:20,2),'b');
load('..\Compiler\oulujarvi_old_code.mat');
clf
plot(results1.Bminor(1:20,2)-Results.allbiomasses(1:20,2),'r');
%hold on
%semilogy(Results.allbiomasses(1:20,2),'b');
%legend({'new','old'});
% Kalastussaaliit