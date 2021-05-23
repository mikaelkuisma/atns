function results = temp_update_code(parameterset, results)
minor_epoch_length = parameterset.minor_epoch_length;
steps_per_minor_epoch = parameterset.steps_per_minor_epoch;
minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
major_epochs = parameterset.major_epochs;
dt = minor_epoch_length / steps_per_minor_epoch;
Prey1_B_i = 0.2000000000000000;
Prey1_alpha_i = 0.3500000000000000;
for major=1:major_epochs
      fprintf('year %d\n', major);
   for minor=1:minor_epochs_per_major_epoch
      for iter=1:steps_per_minor_epoch
       if iter==1
Bflat = [ Prey1_B_i ];
            results.add_minor_epoch(Bflat);
            if minor == 1
                results.add_major_epoch(Bflat);
            end
        end
Bflat = [ Prey1_B_i ];
dPrey1_B_idt = 0;
temp0 = Prey1_alpha_i;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
dPrey1_B_idt = dPrey1_B_idt + temp0;
dBflatdt = [ dPrey1_B_idt ];
Bflat2 = Bflat;
Bflat = Bflat + dBflatdt*dt;
Prey1_B_i = Bflat(1);
dPrey1_B_idt = 0;
temp0 = Prey1_alpha_i;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
dPrey1_B_idt = dPrey1_B_idt + temp0;
dBflat2dt = [ dPrey1_B_idt ];
Bflat = Bflat2 + (dBflatdt+dBflat2dt)*dt/2;
Prey1_B_i = Bflat(1);
      end
   end
Bflat = [ Prey1_B_i ];
dPrey1_B_idt = 0;
temp0 = Prey1_alpha_i;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
dPrey1_B_idt = dPrey1_B_idt + temp0;
dPrey1_B_idt = 0;
dBflatdt = [ dPrey1_B_idt ];
Bflat = Bflat + dBflatdt;
Prey1_B_i = Bflat(1);
dPrey1_B_idt = 0;
temp0 = Prey1_alpha_i;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
dPrey1_B_idt = dPrey1_B_idt + temp0;
end
