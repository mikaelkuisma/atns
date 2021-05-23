function results = temp_update_code(parameterset, results)
minor_epoch_length = parameterset.minor_epoch_length;
steps_per_minor_epoch = parameterset.steps_per_minor_epoch;
minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
major_epochs = parameterset.major_epochs;
dt = minor_epoch_length / steps_per_minor_epoch;
MODULE_Blarvae = 1.0000000000000000;
MODULE_Bjuvenile = 0.0000000000000000;
MODULE_Badult = 0.0000000000000000;
MODULE_Bsenile = 0.0000000000000000;
for major=1:major_epochs
      fprintf('year %d\n', major);
   for minor=1:minor_epochs_per_major_epoch
      for iter=1:steps_per_minor_epoch
       if iter==1
Bflat = [ MODULE_Blarvae MODULE_Bjuvenile MODULE_Badult MODULE_Bsenile ];
            results.add_minor_epoch(Bflat);
            if minor == 1
                results.add_major_epoch(Bflat);
            end
        end
Bflat = [ MODULE_Blarvae MODULE_Bjuvenile MODULE_Badult MODULE_Bsenile ];
dMODULE_Blarvaedt = 0;
dMODULE_Bjuveniledt = 0;
dMODULE_Badultdt = 0;
dMODULE_Bseniledt = 0;
temp0 = 1.000000000000000;
temp1 = MODULE_Blarvae;
temp0 = temp0 * temp1;
MODULE_llarvae = temp0;
temp0 = 0.400000000000000;
temp1 = MODULE_Bjuvenile;
temp0 = temp0 * temp1;
MODULE_ljuvenile = temp0;
temp0 = 0.200000000000000;
temp1 = MODULE_Badult;
temp0 = temp0 * temp1;
MODULE_ladult = temp0;
temp0 = 0.200000000000000;
temp1 = MODULE_Bsenile;
temp0 = temp0 * temp1;
MODULE_lsenile = temp0;
temp0 = MODULE_llarvae;
temp0 = -temp0;
dMODULE_Blarvaedt = dMODULE_Blarvaedt + temp0;
temp0 = MODULE_llarvae;
temp1 = MODULE_ljuvenile;
temp0 = temp0 - temp1;
dMODULE_Bjuveniledt = dMODULE_Bjuveniledt + temp0;
temp0 = MODULE_ljuvenile;
temp1 = MODULE_ladult;
temp0 = temp0 - temp1;
dMODULE_Badultdt = dMODULE_Badultdt + temp0;
temp0 = MODULE_ladult;
temp1 = MODULE_lsenile;
temp0 = temp0 - temp1;
dMODULE_Bseniledt = dMODULE_Bseniledt + temp0;
dBflatdt = [ dMODULE_Blarvaedt dMODULE_Bjuveniledt dMODULE_Badultdt dMODULE_Bseniledt ];
Bflat2 = Bflat;
Bflat = Bflat + dBflatdt*dt;
MODULE_Blarvae = Bflat(1);
MODULE_Bjuvenile = Bflat(2);
MODULE_Badult = Bflat(3);
MODULE_Bsenile = Bflat(4);
dMODULE_Blarvaedt = 0;
dMODULE_Bjuveniledt = 0;
dMODULE_Badultdt = 0;
dMODULE_Bseniledt = 0;
temp0 = 1.000000000000000;
temp1 = MODULE_Blarvae;
temp0 = temp0 * temp1;
MODULE_llarvae = temp0;
temp0 = 0.400000000000000;
temp1 = MODULE_Bjuvenile;
temp0 = temp0 * temp1;
MODULE_ljuvenile = temp0;
temp0 = 0.200000000000000;
temp1 = MODULE_Badult;
temp0 = temp0 * temp1;
MODULE_ladult = temp0;
temp0 = 0.200000000000000;
temp1 = MODULE_Bsenile;
temp0 = temp0 * temp1;
MODULE_lsenile = temp0;
temp0 = MODULE_llarvae;
temp0 = -temp0;
dMODULE_Blarvaedt = dMODULE_Blarvaedt + temp0;
temp0 = MODULE_llarvae;
temp1 = MODULE_ljuvenile;
temp0 = temp0 - temp1;
dMODULE_Bjuveniledt = dMODULE_Bjuveniledt + temp0;
temp0 = MODULE_ljuvenile;
temp1 = MODULE_ladult;
temp0 = temp0 - temp1;
dMODULE_Badultdt = dMODULE_Badultdt + temp0;
temp0 = MODULE_ladult;
temp1 = MODULE_lsenile;
temp0 = temp0 - temp1;
dMODULE_Bseniledt = dMODULE_Bseniledt + temp0;
dBflat2dt = [ dMODULE_Blarvaedt dMODULE_Bjuveniledt dMODULE_Badultdt dMODULE_Bseniledt ];
Bflat = Bflat2 + (dBflatdt+dBflat2dt)*dt/2;
MODULE_Blarvae = Bflat(1);
MODULE_Bjuvenile = Bflat(2);
MODULE_Badult = Bflat(3);
MODULE_Bsenile = Bflat(4);
      end
   end
Bflat = [ MODULE_Blarvae MODULE_Bjuvenile MODULE_Badult MODULE_Bsenile ];
dMODULE_Blarvaedt = 0;
dMODULE_Bjuveniledt = 0;
dMODULE_Badultdt = 0;
dMODULE_Bseniledt = 0;
temp0 = 1.000000000000000;
temp1 = MODULE_Blarvae;
temp0 = temp0 * temp1;
MODULE_llarvae = temp0;
temp0 = 0.400000000000000;
temp1 = MODULE_Bjuvenile;
temp0 = temp0 * temp1;
MODULE_ljuvenile = temp0;
temp0 = 0.200000000000000;
temp1 = MODULE_Badult;
temp0 = temp0 * temp1;
MODULE_ladult = temp0;
temp0 = 0.200000000000000;
temp1 = MODULE_Bsenile;
temp0 = temp0 * temp1;
MODULE_lsenile = temp0;
temp0 = MODULE_llarvae;
temp0 = -temp0;
dMODULE_Blarvaedt = dMODULE_Blarvaedt + temp0;
temp0 = MODULE_llarvae;
temp1 = MODULE_ljuvenile;
temp0 = temp0 - temp1;
dMODULE_Bjuveniledt = dMODULE_Bjuveniledt + temp0;
temp0 = MODULE_ljuvenile;
temp1 = MODULE_ladult;
temp0 = temp0 - temp1;
dMODULE_Badultdt = dMODULE_Badultdt + temp0;
temp0 = MODULE_ladult;
temp1 = MODULE_lsenile;
temp0 = temp0 - temp1;
dMODULE_Bseniledt = dMODULE_Bseniledt + temp0;
dMODULE_Blarvaedt = 0;
dMODULE_Bjuveniledt = 0;
dMODULE_Badultdt = 0;
dMODULE_Bseniledt = 0;
dBflatdt = [ dMODULE_Blarvaedt dMODULE_Bjuveniledt dMODULE_Badultdt dMODULE_Bseniledt ];
Bflat = Bflat + dBflatdt;
MODULE_Blarvae = Bflat(1);
MODULE_Bjuvenile = Bflat(2);
MODULE_Badult = Bflat(3);
MODULE_Bsenile = Bflat(4);
dMODULE_Blarvaedt = 0;
dMODULE_Bjuveniledt = 0;
dMODULE_Badultdt = 0;
dMODULE_Bseniledt = 0;
temp0 = 1.000000000000000;
temp1 = MODULE_Blarvae;
temp0 = temp0 * temp1;
MODULE_llarvae = temp0;
temp0 = 0.400000000000000;
temp1 = MODULE_Bjuvenile;
temp0 = temp0 * temp1;
MODULE_ljuvenile = temp0;
temp0 = 0.200000000000000;
temp1 = MODULE_Badult;
temp0 = temp0 * temp1;
MODULE_ladult = temp0;
temp0 = 0.200000000000000;
temp1 = MODULE_Bsenile;
temp0 = temp0 * temp1;
MODULE_lsenile = temp0;
temp0 = MODULE_llarvae;
temp0 = -temp0;
dMODULE_Blarvaedt = dMODULE_Blarvaedt + temp0;
temp0 = MODULE_llarvae;
temp1 = MODULE_ljuvenile;
temp0 = temp0 - temp1;
dMODULE_Bjuveniledt = dMODULE_Bjuveniledt + temp0;
temp0 = MODULE_ljuvenile;
temp1 = MODULE_ladult;
temp0 = temp0 - temp1;
dMODULE_Badultdt = dMODULE_Badultdt + temp0;
temp0 = MODULE_ladult;
temp1 = MODULE_lsenile;
temp0 = temp0 - temp1;
dMODULE_Bseniledt = dMODULE_Bseniledt + temp0;
end
