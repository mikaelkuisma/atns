function results = temp_update_code(parameterset, results)
minor_epoch_length = parameterset.minor_epoch_length;
steps_per_minor_epoch = parameterset.steps_per_minor_epoch;
minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
major_epochs = parameterset.major_epochs;
dt = minor_epoch_length / steps_per_minor_epoch;
for major=1:major_epochs
      fprintf('year %d\n', major);
   for minor=1:minor_epochs_per_major_epoch
      for iter=1:steps_per_minor_epoch
       if iter==1
Bflat = [ ];
            results.add_minor_epoch(Bflat);
            if minor == 1
                results.add_major_epoch(Bflat);
            end
        end
Bflat = [ ];
dBflatdt = [ ];
Bflat2 = Bflat;
Bflat = Bflat + dBflatdt*dt;
dBflat2dt = [ ];
Bflat = Bflat2 + (dBflatdt+dBflat2dt)*dt/2;
      end
   end
Bflat = [ ];
dBflatdt = [ ];
Bflat = Bflat + dBflatdt;
end
