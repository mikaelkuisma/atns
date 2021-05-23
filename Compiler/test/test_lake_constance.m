% Store old path, to restore it after the test
current_path = cd;

% Path to this file
[filepath,name,ext] = fileparts(mfilename('fullpath'));

% Path to LakeConstance mat-model
mat_model = fullfile(filepath, 'old\Data\1_LakeConstance.mat');

% Go to test directory
cd(filepath);

migration(mat_model, 'test_lake_constance.generated_model','modelfile','test_lake_constance.model');
results_new = atnsf('test_lake_constance.generated_model',1,'new','years', 30, 'steps_per_day',10).Bminor;

results_new = results_new([1 2 3:22 23:2:42],:);
clf
semilogy(results_new','r','linewidth',2);
hold on


cd(fullfile(filepath, 'old'));

results = test_suite_old_run(mat_model, odeset('RelTol',1e-9,'AbsTol',1e-10));
old_results = reshape(results.allbiomasses, size(results.allbiomasses,1), 91, 30);
old_results = reshape(old_results(:,1:90,:), size(results.allbiomasses,1), 90*30);
semilogy(old_results','b--','linewidth',2);

x0=10;
y0=10;
width=1500;
height=1000
set(gcf,'position',[x0,y0,width,height])
set(gca,'Fontsize',22);
ylabel('Biomass [\muC/m^3]','Fontsize',22);
xlabel('Day','Fontsize',22);
print -dpng lake_constance_oldnew.png

cd(current_path);

deviation = results_new(:,1:2700)-old_results(:,1:2700);
clf
semilogy((abs(deviation) ./ results_new(:,1:2700))','r','Linewidth',2);
ylabel('Relative deviation','Fontsize',22);
xlabel('Day','Fontsize',22);
ylim([1e-7 1e-2]);
set(gca,'Fontsize',22);
print -dpng lake_constance_deviation.png
assert(std(deviation(:))<1.1);