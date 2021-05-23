function results = temp_update_code(parameterset, results)
minor_epoch_length = parameterset.minor_epoch_length;
steps_per_minor_epoch = parameterset.steps_per_minor_epoch;
minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
major_epochs = parameterset.major_epochs;
dt = minor_epoch_length / steps_per_minor_epoch;
MODULE_B1 = 1.0000000000000000;
MODULE_B2 = 0.0000000000000000;
MODULE_B3 = 0.0000000000000000;
MODULE_B4 = 0.0000000000000000;
for major=1:major_epochs
      fprintf('year %d\n', major);
   for minor=1:minor_epochs_per_major_epoch
      for iter=1:steps_per_minor_epoch
       if iter==1
Bflat = [ MODULE_B1 MODULE_B2 MODULE_B3 MODULE_B4 ];
            results.add_minor_epoch(Bflat);
            if minor == 1
                results.add_major_epoch(Bflat);
            end
        end
Bflat = [ MODULE_B1 MODULE_B2 MODULE_B3 MODULE_B4 ];
dMODULE_B1dt = 0;
dMODULE_B2dt = 0;
dMODULE_B3dt = 0;
dMODULE_B4dt = 0;
temp0 = MODULE_B1;
temp1 = 15.000000000000000;
temp0 = temp0 / temp1;
temp0 = -temp0;
dMODULE_B1dt = dMODULE_B1dt + temp0;
temp0 = MODULE_B2;
temp1 = 15.000000000000000;
temp0 = temp0 / temp1;
dMODULE_B2dt = dMODULE_B2dt + temp0;
temp0 = MODULE_B3;
temp1 = 25.000000000000000;
temp0 = temp0 / temp1;
temp0 = -temp0;
dMODULE_B3dt = dMODULE_B3dt + temp0;
temp0 = MODULE_B4;
temp1 = 25.000000000000000;
temp0 = temp0 / temp1;
dMODULE_B4dt = dMODULE_B4dt + temp0;
dBflatdt = [ dMODULE_B1dt dMODULE_B2dt dMODULE_B3dt dMODULE_B4dt ];
Bflat2 = Bflat;
Bflat = Bflat + dBflatdt*dt;
MODULE_B1 = Bflat(1);
MODULE_B2 = Bflat(2);
MODULE_B3 = Bflat(3);
MODULE_B4 = Bflat(4);
dMODULE_B1dt = 0;
dMODULE_B2dt = 0;
dMODULE_B3dt = 0;
dMODULE_B4dt = 0;
temp0 = MODULE_B1;
temp1 = 15.000000000000000;
temp0 = temp0 / temp1;
temp0 = -temp0;
dMODULE_B1dt = dMODULE_B1dt + temp0;
temp0 = MODULE_B2;
temp1 = 15.000000000000000;
temp0 = temp0 / temp1;
dMODULE_B2dt = dMODULE_B2dt + temp0;
temp0 = MODULE_B3;
temp1 = 25.000000000000000;
temp0 = temp0 / temp1;
temp0 = -temp0;
dMODULE_B3dt = dMODULE_B3dt + temp0;
temp0 = MODULE_B4;
temp1 = 25.000000000000000;
temp0 = temp0 / temp1;
dMODULE_B4dt = dMODULE_B4dt + temp0;
dBflat2dt = [ dMODULE_B1dt dMODULE_B2dt dMODULE_B3dt dMODULE_B4dt ];
Bflat = Bflat2 + (dBflatdt+dBflat2dt)*dt/2;
MODULE_B1 = Bflat(1);
MODULE_B2 = Bflat(2);
MODULE_B3 = Bflat(3);
MODULE_B4 = Bflat(4);
      end
   end
Bflat = [ MODULE_B1 MODULE_B2 MODULE_B3 MODULE_B4 ];
dMODULE_B1dt = 0;
dMODULE_B2dt = 0;
dMODULE_B3dt = 0;
dMODULE_B4dt = 0;
temp0 = MODULE_B1;
temp1 = 15.000000000000000;
temp0 = temp0 / temp1;
temp0 = -temp0;
dMODULE_B1dt = dMODULE_B1dt + temp0;
temp0 = MODULE_B2;
temp1 = 15.000000000000000;
temp0 = temp0 / temp1;
dMODULE_B2dt = dMODULE_B2dt + temp0;
temp0 = MODULE_B3;
temp1 = 25.000000000000000;
temp0 = temp0 / temp1;
temp0 = -temp0;
dMODULE_B3dt = dMODULE_B3dt + temp0;
temp0 = MODULE_B4;
temp1 = 25.000000000000000;
temp0 = temp0 / temp1;
dMODULE_B4dt = dMODULE_B4dt + temp0;
dMODULE_B1dt = 0;
dMODULE_B2dt = 0;
dMODULE_B3dt = 0;
dMODULE_B4dt = 0;
temp0 = MODULE_B1;
temp0 = -temp0;
dMODULE_B1dt = dMODULE_B1dt + temp0;
temp0 = MODULE_B1;
dMODULE_B2dt = dMODULE_B2dt + temp0;
temp0 = MODULE_B2;
temp0 = -temp0;
dMODULE_B2dt = dMODULE_B2dt + temp0;
temp0 = MODULE_B2;
dMODULE_B3dt = dMODULE_B3dt + temp0;
temp0 = MODULE_B3;
temp0 = -temp0;
dMODULE_B3dt = dMODULE_B3dt + temp0;
temp0 = MODULE_B3;
dMODULE_B4dt = dMODULE_B4dt + temp0;
dBflatdt = [ dMODULE_B1dt dMODULE_B2dt dMODULE_B3dt dMODULE_B4dt ];
Bflat = Bflat + dBflatdt;
MODULE_B1 = Bflat(1);
MODULE_B2 = Bflat(2);
MODULE_B3 = Bflat(3);
MODULE_B4 = Bflat(4);
dMODULE_B1dt = 0;
dMODULE_B2dt = 0;
dMODULE_B3dt = 0;
dMODULE_B4dt = 0;
temp0 = MODULE_B1;
temp1 = 15.000000000000000;
temp0 = temp0 / temp1;
temp0 = -temp0;
dMODULE_B1dt = dMODULE_B1dt + temp0;
temp0 = MODULE_B2;
temp1 = 15.000000000000000;
temp0 = temp0 / temp1;
dMODULE_B2dt = dMODULE_B2dt + temp0;
temp0 = MODULE_B3;
temp1 = 25.000000000000000;
temp0 = temp0 / temp1;
temp0 = -temp0;
dMODULE_B3dt = dMODULE_B3dt + temp0;
temp0 = MODULE_B4;
temp1 = 25.000000000000000;
temp0 = temp0 / temp1;
dMODULE_B4dt = dMODULE_B4dt + temp0;
end
