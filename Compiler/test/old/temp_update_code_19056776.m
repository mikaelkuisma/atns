function results = temp_update_code(parameterset, results)
minor_epoch_length = parameterset.minor_epoch_length;
steps_per_minor_epoch = parameterset.steps_per_minor_epoch;
minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
major_epochs = parameterset.major_epochs;
dt = minor_epoch_length / steps_per_minor_epoch;
Prey_B_i = 2.0000000000000000;
Predator_B_i = 1.0000000000000000;
for major=1:major_epochs
      fprintf('year %d\n', major);
   for minor=1:minor_epochs_per_major_epoch
      for iter=1:steps_per_minor_epoch
       if iter==1
Bflat = [ Prey_B_i Predator_B_i ];
            results.add_minor_epoch(Bflat);
            if minor == 1
                results.add_major_epoch(Bflat);
            end
        end
Bflat = [ Prey_B_i Predator_B_i ];
dPrey_B_idt = 0;
dPredator_B_idt = 0;
temp0 = 1.000000000000000;
dPrey_B_idt = dPrey_B_idt + temp0;
temp0 = 2.000000000000000;
dPredator_B_idt = dPredator_B_idt + temp0;
dBflatdt = [ dPrey_B_idt dPredator_B_idt ];
Bflat2 = Bflat;
Bflat = Bflat + dBflatdt*dt;
Prey_B_i = Bflat(1);
Predator_B_i = Bflat(2);
dPrey_B_idt = 0;
dPredator_B_idt = 0;
temp0 = 1.000000000000000;
dPrey_B_idt = dPrey_B_idt + temp0;
temp0 = 2.000000000000000;
dPredator_B_idt = dPredator_B_idt + temp0;
dBflat2dt = [ dPrey_B_idt dPredator_B_idt ];
Bflat = Bflat2 + (dBflatdt+dBflat2dt)*dt/2;
Prey_B_i = Bflat(1);
Predator_B_i = Bflat(2);
      end
   end
Bflat = [ Prey_B_i Predator_B_i ];
dPrey_B_idt = 0;
dPredator_B_idt = 0;
temp0 = 1.000000000000000;
dPrey_B_idt = dPrey_B_idt + temp0;
temp0 = 2.000000000000000;
dPredator_B_idt = dPredator_B_idt + temp0;
dPrey_B_idt = 0;
dPredator_B_idt = 0;
dBflatdt = [ dPrey_B_idt dPredator_B_idt ];
Bflat = Bflat + dBflatdt;
Prey_B_i = Bflat(1);
Predator_B_i = Bflat(2);
dPrey_B_idt = 0;
dPredator_B_idt = 0;
temp0 = 1.000000000000000;
dPrey_B_idt = dPrey_B_idt + temp0;
temp0 = 2.000000000000000;
dPredator_B_idt = dPredator_B_idt + temp0;
end
