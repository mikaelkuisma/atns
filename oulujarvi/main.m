migration('5pros_oulujarvi_old_period.mat', 'oulujarvi.model');
results = atnsf('runoulujarvi.model');
results.structured_plot_age_groups();
