migration('5pros_oulujarvi_old_period.mat', 'oulujarvi.generated_model','modelfile','atn_with_fishing.model');
results = atnsf('runoulujarvi.model');
results.structured_plot_age_groups();

% Kalastussaaliit