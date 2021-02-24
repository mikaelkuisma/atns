function results = temp_update_code(parameterset, results)
minor_epoch_length = parameterset.minor_epoch_length;
steps_per_minor_epoch = parameterset.steps_per_minor_epoch;
minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
major_epochs = parameterset.major_epochs;
dt = minor_epoch_length / steps_per_minor_epoch;
MODULE_A = 1.0000000000000000;
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
% 0065 RET 
% 0066 RET 
dBflatdt = [ ];
Bflat2 = Bflat;
Bflat = Bflat + dBflatdt*dt;
% 0065 RET 
% 0066 RET 
dBflat2dt = [ ];
Bflat = Bflat2 + (dBflatdt+dBflat2dt)*dt/2;
      end
   end
Bflat = [ ];
% 0065 RET 
% 0066 RET 
% 0067 RET 
dBflatdt = [ ];
Bflat = Bflat + dBflatdt;
% 0065 RET 
% 0066 RET 
end
