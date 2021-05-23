function results = temp_update_code(parameterset, results)
minor_epoch_length = parameterset.minor_epoch_length;
steps_per_minor_epoch = parameterset.steps_per_minor_epoch;
minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
major_epochs = parameterset.major_epochs;
dt = minor_epoch_length / steps_per_minor_epoch;
Prey1_B_i = 0.2000000000000000;
Prey2_B_i = 0.3000000000000000;
Predator_B_i = 0.9000000000000000;
TopLevelPredator_B_i = 2.0000000000000000;
Prey1_alpha_i = 1.0000000000000000;
Prey2_alpha_i = 1.0000000000000000;
Predator_alpha_i = -1.0000000000000000;
TopLevelPredator_alpha_i = -0.0300000000000000;
Feed_link1_gamma_ij = 0.7000000000000000;
Feed_link2_gamma_ij = 0.5000000000000000;
Feed_link3_gamma_ij = 0.0300000000000000;
for major=1:major_epochs
      fprintf('year %d\n', major);
   for minor=1:minor_epochs_per_major_epoch
      for iter=1:steps_per_minor_epoch
       if iter==1
Bflat = [ Prey1_B_i Prey2_B_i Predator_B_i TopLevelPredator_B_i ];
            results.add_minor_epoch(Bflat);
            if minor == 1
                results.add_major_epoch(Bflat);
            end
        end
Bflat = [ Prey1_B_i Prey2_B_i Predator_B_i TopLevelPredator_B_i ];
dPrey1_B_idt = 0;
dPrey2_B_idt = 0;
dPredator_B_idt = 0;
dTopLevelPredator_B_idt = 0;
temp0 = Prey1_alpha_i;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
dPrey1_B_idt = dPrey1_B_idt + temp0;
temp0 = Prey2_alpha_i;
temp1 = Prey2_B_i;
temp0 = temp0 * temp1;
dPrey2_B_idt = dPrey2_B_idt + temp0;
temp0 = Predator_alpha_i;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = TopLevelPredator_alpha_i;
temp1 = TopLevelPredator_B_i;
temp0 = temp0 * temp1;
dTopLevelPredator_B_idt = dTopLevelPredator_B_idt + temp0;
temp0 = Feed_link1_gamma_ij;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
Feed_link1_rate_ij = temp0;
temp0 = Feed_link2_gamma_ij;
temp1 = Prey2_B_i;
temp0 = temp0 * temp1;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
Feed_link2_rate_ij = temp0;
temp0 = Feed_link3_gamma_ij;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
temp1 = TopLevelPredator_B_i;
temp0 = temp0 * temp1;
Feed_link3_rate_ij = temp0;
temp0 = Feed_link1_rate_ij;
temp0 = -temp0;
dPrey1_B_idt = dPrey1_B_idt + temp0;
temp0 = Feed_link2_rate_ij;
temp0 = -temp0;
dPrey2_B_idt = dPrey2_B_idt + temp0;
temp0 = Feed_link3_rate_ij;
temp0 = -temp0;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link1_rate_ij;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link2_rate_ij;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link3_rate_ij;
dTopLevelPredator_B_idt = dTopLevelPredator_B_idt + temp0;
dBflatdt = [ dPrey1_B_idt dPrey2_B_idt dPredator_B_idt dTopLevelPredator_B_idt ];
Bflat2 = Bflat;
Bflat = Bflat + dBflatdt*dt;
Prey1_B_i = Bflat(1);
Prey2_B_i = Bflat(2);
Predator_B_i = Bflat(3);
TopLevelPredator_B_i = Bflat(4);
dPrey1_B_idt = 0;
dPrey2_B_idt = 0;
dPredator_B_idt = 0;
dTopLevelPredator_B_idt = 0;
temp0 = Prey1_alpha_i;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
dPrey1_B_idt = dPrey1_B_idt + temp0;
temp0 = Prey2_alpha_i;
temp1 = Prey2_B_i;
temp0 = temp0 * temp1;
dPrey2_B_idt = dPrey2_B_idt + temp0;
temp0 = Predator_alpha_i;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = TopLevelPredator_alpha_i;
temp1 = TopLevelPredator_B_i;
temp0 = temp0 * temp1;
dTopLevelPredator_B_idt = dTopLevelPredator_B_idt + temp0;
temp0 = Feed_link1_gamma_ij;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
Feed_link1_rate_ij = temp0;
temp0 = Feed_link2_gamma_ij;
temp1 = Prey2_B_i;
temp0 = temp0 * temp1;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
Feed_link2_rate_ij = temp0;
temp0 = Feed_link3_gamma_ij;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
temp1 = TopLevelPredator_B_i;
temp0 = temp0 * temp1;
Feed_link3_rate_ij = temp0;
temp0 = Feed_link1_rate_ij;
temp0 = -temp0;
dPrey1_B_idt = dPrey1_B_idt + temp0;
temp0 = Feed_link2_rate_ij;
temp0 = -temp0;
dPrey2_B_idt = dPrey2_B_idt + temp0;
temp0 = Feed_link3_rate_ij;
temp0 = -temp0;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link1_rate_ij;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link2_rate_ij;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link3_rate_ij;
dTopLevelPredator_B_idt = dTopLevelPredator_B_idt + temp0;
dBflat2dt = [ dPrey1_B_idt dPrey2_B_idt dPredator_B_idt dTopLevelPredator_B_idt ];
Bflat = Bflat2 + (dBflatdt+dBflat2dt)*dt/2;
Prey1_B_i = Bflat(1);
Prey2_B_i = Bflat(2);
Predator_B_i = Bflat(3);
TopLevelPredator_B_i = Bflat(4);
      end
   end
Bflat = [ Prey1_B_i Prey2_B_i Predator_B_i TopLevelPredator_B_i ];
dPrey1_B_idt = 0;
dPrey2_B_idt = 0;
dPredator_B_idt = 0;
dTopLevelPredator_B_idt = 0;
temp0 = Prey1_alpha_i;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
dPrey1_B_idt = dPrey1_B_idt + temp0;
temp0 = Prey2_alpha_i;
temp1 = Prey2_B_i;
temp0 = temp0 * temp1;
dPrey2_B_idt = dPrey2_B_idt + temp0;
temp0 = Predator_alpha_i;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = TopLevelPredator_alpha_i;
temp1 = TopLevelPredator_B_i;
temp0 = temp0 * temp1;
dTopLevelPredator_B_idt = dTopLevelPredator_B_idt + temp0;
temp0 = Feed_link1_gamma_ij;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
Feed_link1_rate_ij = temp0;
temp0 = Feed_link2_gamma_ij;
temp1 = Prey2_B_i;
temp0 = temp0 * temp1;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
Feed_link2_rate_ij = temp0;
temp0 = Feed_link3_gamma_ij;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
temp1 = TopLevelPredator_B_i;
temp0 = temp0 * temp1;
Feed_link3_rate_ij = temp0;
temp0 = Feed_link1_rate_ij;
temp0 = -temp0;
dPrey1_B_idt = dPrey1_B_idt + temp0;
temp0 = Feed_link2_rate_ij;
temp0 = -temp0;
dPrey2_B_idt = dPrey2_B_idt + temp0;
temp0 = Feed_link3_rate_ij;
temp0 = -temp0;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link1_rate_ij;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link2_rate_ij;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link3_rate_ij;
dTopLevelPredator_B_idt = dTopLevelPredator_B_idt + temp0;
dPrey1_B_idt = 0;
dPrey2_B_idt = 0;
dPredator_B_idt = 0;
dTopLevelPredator_B_idt = 0;
dBflatdt = [ dPrey1_B_idt dPrey2_B_idt dPredator_B_idt dTopLevelPredator_B_idt ];
Bflat = Bflat + dBflatdt;
Prey1_B_i = Bflat(1);
Prey2_B_i = Bflat(2);
Predator_B_i = Bflat(3);
TopLevelPredator_B_i = Bflat(4);
dPrey1_B_idt = 0;
dPrey2_B_idt = 0;
dPredator_B_idt = 0;
dTopLevelPredator_B_idt = 0;
temp0 = Prey1_alpha_i;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
dPrey1_B_idt = dPrey1_B_idt + temp0;
temp0 = Prey2_alpha_i;
temp1 = Prey2_B_i;
temp0 = temp0 * temp1;
dPrey2_B_idt = dPrey2_B_idt + temp0;
temp0 = Predator_alpha_i;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = TopLevelPredator_alpha_i;
temp1 = TopLevelPredator_B_i;
temp0 = temp0 * temp1;
dTopLevelPredator_B_idt = dTopLevelPredator_B_idt + temp0;
temp0 = Feed_link1_gamma_ij;
temp1 = Prey1_B_i;
temp0 = temp0 * temp1;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
Feed_link1_rate_ij = temp0;
temp0 = Feed_link2_gamma_ij;
temp1 = Prey2_B_i;
temp0 = temp0 * temp1;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
Feed_link2_rate_ij = temp0;
temp0 = Feed_link3_gamma_ij;
temp1 = Predator_B_i;
temp0 = temp0 * temp1;
temp1 = TopLevelPredator_B_i;
temp0 = temp0 * temp1;
Feed_link3_rate_ij = temp0;
temp0 = Feed_link1_rate_ij;
temp0 = -temp0;
dPrey1_B_idt = dPrey1_B_idt + temp0;
temp0 = Feed_link2_rate_ij;
temp0 = -temp0;
dPrey2_B_idt = dPrey2_B_idt + temp0;
temp0 = Feed_link3_rate_ij;
temp0 = -temp0;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link1_rate_ij;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link2_rate_ij;
dPredator_B_idt = dPredator_B_idt + temp0;
temp0 = Feed_link3_rate_ij;
dTopLevelPredator_B_idt = dTopLevelPredator_B_idt + temp0;
end
