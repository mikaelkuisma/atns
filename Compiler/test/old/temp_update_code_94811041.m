function results = temp_update_code(parameterset, results)
minor_epoch_length = parameterset.minor_epoch_length;
steps_per_minor_epoch = parameterset.steps_per_minor_epoch;
minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
major_epochs = parameterset.major_epochs;
dt = minor_epoch_length / steps_per_minor_epoch;
MODULE_B1 = 0.6666666666666666;
MODULE_B2 = 0.5000000000000000;
MODULE_alpha = 1.0000000000000000;
MODULE_beta = 1.0000000000000000;
MODULE_gamma = 1.0000000000000000;
for major=1:major_epochs
      fprintf('year %d\n', major);
   for minor=1:minor_epochs_per_major_epoch
      for iter=1:steps_per_minor_epoch
       if iter==1
Bflat = [ MODULE_B1 MODULE_B2 ];
            results.add_minor_epoch(Bflat);
            if minor == 1
                results.add_major_epoch(Bflat);
            end
        end
Bflat = [ MODULE_B1 MODULE_B2 ];
dMODULE_B1dt = 0;
dMODULE_B2dt = 0;
temp0 = MODULE_alpha;
temp1 = MODULE_B1;
temp0 = temp0 * temp1;
temp1 = MODULE_gamma;
temp2 = MODULE_B1;
temp1 = temp1 * temp2;
temp2 = MODULE_B2;
temp1 = temp1 * temp2;
temp0 = temp0 - temp1;
dMODULE_B1dt = dMODULE_B1dt + temp0;
temp0 = MODULE_beta;
temp1 = MODULE_B2;
temp0 = temp0 * temp1;
temp0 = -temp0;
temp1 = MODULE_gamma;
temp2 = MODULE_B1;
temp1 = temp1 * temp2;
temp2 = MODULE_B2;
temp1 = temp1 * temp2;
temp0 = temp0 + temp1;
dMODULE_B2dt = dMODULE_B2dt + temp0;
dBflatdt = [ dMODULE_B1dt dMODULE_B2dt ];
Bflat2 = Bflat;
Bflat = Bflat + dBflatdt*dt;
MODULE_B1 = Bflat(1);
MODULE_B2 = Bflat(2);
dMODULE_B1dt = 0;
dMODULE_B2dt = 0;
temp0 = MODULE_alpha;
temp1 = MODULE_B1;
temp0 = temp0 * temp1;
temp1 = MODULE_gamma;
temp2 = MODULE_B1;
temp1 = temp1 * temp2;
temp2 = MODULE_B2;
temp1 = temp1 * temp2;
temp0 = temp0 - temp1;
dMODULE_B1dt = dMODULE_B1dt + temp0;
temp0 = MODULE_beta;
temp1 = MODULE_B2;
temp0 = temp0 * temp1;
temp0 = -temp0;
temp1 = MODULE_gamma;
temp2 = MODULE_B1;
temp1 = temp1 * temp2;
temp2 = MODULE_B2;
temp1 = temp1 * temp2;
temp0 = temp0 + temp1;
dMODULE_B2dt = dMODULE_B2dt + temp0;
dBflat2dt = [ dMODULE_B1dt dMODULE_B2dt ];
Bflat = Bflat2 + (dBflatdt+dBflat2dt)*dt/2;
MODULE_B1 = Bflat(1);
MODULE_B2 = Bflat(2);
      end
   end
Bflat = [ MODULE_B1 MODULE_B2 ];
dMODULE_B1dt = 0;
dMODULE_B2dt = 0;
temp0 = MODULE_alpha;
temp1 = MODULE_B1;
temp0 = temp0 * temp1;
temp1 = MODULE_gamma;
temp2 = MODULE_B1;
temp1 = temp1 * temp2;
temp2 = MODULE_B2;
temp1 = temp1 * temp2;
temp0 = temp0 - temp1;
dMODULE_B1dt = dMODULE_B1dt + temp0;
temp0 = MODULE_beta;
temp1 = MODULE_B2;
temp0 = temp0 * temp1;
temp0 = -temp0;
temp1 = MODULE_gamma;
temp2 = MODULE_B1;
temp1 = temp1 * temp2;
temp2 = MODULE_B2;
temp1 = temp1 * temp2;
temp0 = temp0 + temp1;
dMODULE_B2dt = dMODULE_B2dt + temp0;
dMODULE_B1dt = 0;
dMODULE_B2dt = 0;
dBflatdt = [ dMODULE_B1dt dMODULE_B2dt ];
Bflat = Bflat + dBflatdt;
MODULE_B1 = Bflat(1);
MODULE_B2 = Bflat(2);
dMODULE_B1dt = 0;
dMODULE_B2dt = 0;
temp0 = MODULE_alpha;
temp1 = MODULE_B1;
temp0 = temp0 * temp1;
temp1 = MODULE_gamma;
temp2 = MODULE_B1;
temp1 = temp1 * temp2;
temp2 = MODULE_B2;
temp1 = temp1 * temp2;
temp0 = temp0 - temp1;
dMODULE_B1dt = dMODULE_B1dt + temp0;
temp0 = MODULE_beta;
temp1 = MODULE_B2;
temp0 = temp0 * temp1;
temp0 = -temp0;
temp1 = MODULE_gamma;
temp2 = MODULE_B1;
temp1 = temp1 * temp2;
temp2 = MODULE_B2;
temp1 = temp1 * temp2;
temp0 = temp0 + temp1;
dMODULE_B2dt = dMODULE_B2dt + temp0;
end
