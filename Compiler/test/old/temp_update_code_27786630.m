function results = temp_update_code(parameterset, results)
minor_epoch_length = parameterset.minor_epoch_length;
steps_per_minor_epoch = parameterset.steps_per_minor_epoch;
minor_epochs_per_major_epoch = parameterset.minor_epochs_per_major_epoch;
major_epochs = parameterset.major_epochs;
dt = minor_epoch_length / steps_per_minor_epoch;
Producer_intra = 2.0000000000000000;
Producer_inter = 1.0000000000000000;
Producer_K = 5400000.0000000000000000;
Alg1_B_i = 2000.0000000000000000;
Alg2_B_i = 3000.0000000000000000;
Alg3_B_i = 2000.0000000000000000;
Alg4_B_i = 3000.0000000000000000;
Alg5_B_i = 2000.0000000000000000;
Alg6_B_i = 3000.0000000000000000;
Alg1_igr_i = 1.0000000000000000;
Alg1_s_i = 0.0000000000000000;
Alg1_g_i = 0.0000000000000000;
Alg2_igr_i = 1.0000000000000000;
Alg2_s_i = 0.0000000000000000;
Alg2_g_i = 0.0000000000000000;
Alg3_igr_i = 1.0000000000000000;
Alg3_s_i = 0.0000000000000000;
Alg3_g_i = 0.0000000000000000;
Alg4_igr_i = 1.0000000000000000;
Alg4_s_i = 0.0000000000000000;
Alg4_g_i = 0.0000000000000000;
Alg5_igr_i = 1.0000000000000000;
Alg5_s_i = 0.0000000000000000;
Alg5_g_i = 0.0000000000000000;
Alg6_igr_i = 1.0000000000000000;
Alg6_s_i = 0.0000000000000000;
Alg6_g_i = 0.0000000000000000;
for major=1:major_epochs
      fprintf('year %d\n', major);
   for minor=1:minor_epochs_per_major_epoch
      for iter=1:steps_per_minor_epoch
       if iter==1
Bflat = [ Alg1_B_i Alg2_B_i Alg3_B_i Alg4_B_i Alg5_B_i Alg6_B_i ];
            results.add_minor_epoch(Bflat);
            if minor == 1
                results.add_major_epoch(Bflat);
            end
        end
Bflat = [ Alg1_B_i Alg2_B_i Alg3_B_i Alg4_B_i Alg5_B_i Alg6_B_i ];
dAlg1_B_idt = 0;
dAlg2_B_idt = 0;
dAlg3_B_idt = 0;
dAlg4_B_idt = 0;
dAlg5_B_idt = 0;
dAlg6_B_idt = 0;
temp0 = 0;
temp1 = Alg1_B_i;
temp0 = temp0 + temp1;
temp1 = Alg2_B_i;
temp0 = temp0 + temp1;
temp1 = Alg3_B_i;
temp0 = temp0 + temp1;
temp1 = Alg4_B_i;
temp0 = temp0 + temp1;
temp1 = Alg5_B_i;
temp0 = temp0 + temp1;
temp1 = Alg6_B_i;
temp0 = temp0 + temp1;
Producer_total = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg1_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg1_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg2_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg2_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg3_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg3_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg4_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg4_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg5_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg5_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg6_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg6_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Alg1_s_i;
temp0 = temp0 - temp1;
temp1 = Alg1_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg1_g_i;
temp0 = temp0 * temp1;
temp1 = Alg1_B_i;
temp0 = temp0 * temp1;
dAlg1_B_idt = dAlg1_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg2_s_i;
temp0 = temp0 - temp1;
temp1 = Alg2_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg2_g_i;
temp0 = temp0 * temp1;
temp1 = Alg2_B_i;
temp0 = temp0 * temp1;
dAlg2_B_idt = dAlg2_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg3_s_i;
temp0 = temp0 - temp1;
temp1 = Alg3_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg3_g_i;
temp0 = temp0 * temp1;
temp1 = Alg3_B_i;
temp0 = temp0 * temp1;
dAlg3_B_idt = dAlg3_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg4_s_i;
temp0 = temp0 - temp1;
temp1 = Alg4_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg4_g_i;
temp0 = temp0 * temp1;
temp1 = Alg4_B_i;
temp0 = temp0 * temp1;
dAlg4_B_idt = dAlg4_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg5_s_i;
temp0 = temp0 - temp1;
temp1 = Alg5_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg5_g_i;
temp0 = temp0 * temp1;
temp1 = Alg5_B_i;
temp0 = temp0 * temp1;
dAlg5_B_idt = dAlg5_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg6_s_i;
temp0 = temp0 - temp1;
temp1 = Alg6_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg6_g_i;
temp0 = temp0 * temp1;
temp1 = Alg6_B_i;
temp0 = temp0 * temp1;
dAlg6_B_idt = dAlg6_B_idt + temp0;
dBflatdt = [ dAlg1_B_idt dAlg2_B_idt dAlg3_B_idt dAlg4_B_idt dAlg5_B_idt dAlg6_B_idt ];
Bflat2 = Bflat;
Bflat = Bflat + dBflatdt*dt;
Alg1_B_i = Bflat(1);
Alg2_B_i = Bflat(2);
Alg3_B_i = Bflat(3);
Alg4_B_i = Bflat(4);
Alg5_B_i = Bflat(5);
Alg6_B_i = Bflat(6);
dAlg1_B_idt = 0;
dAlg2_B_idt = 0;
dAlg3_B_idt = 0;
dAlg4_B_idt = 0;
dAlg5_B_idt = 0;
dAlg6_B_idt = 0;
temp0 = 0;
temp1 = Alg1_B_i;
temp0 = temp0 + temp1;
temp1 = Alg2_B_i;
temp0 = temp0 + temp1;
temp1 = Alg3_B_i;
temp0 = temp0 + temp1;
temp1 = Alg4_B_i;
temp0 = temp0 + temp1;
temp1 = Alg5_B_i;
temp0 = temp0 + temp1;
temp1 = Alg6_B_i;
temp0 = temp0 + temp1;
Producer_total = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg1_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg1_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg2_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg2_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg3_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg3_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg4_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg4_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg5_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg5_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg6_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg6_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Alg1_s_i;
temp0 = temp0 - temp1;
temp1 = Alg1_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg1_g_i;
temp0 = temp0 * temp1;
temp1 = Alg1_B_i;
temp0 = temp0 * temp1;
dAlg1_B_idt = dAlg1_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg2_s_i;
temp0 = temp0 - temp1;
temp1 = Alg2_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg2_g_i;
temp0 = temp0 * temp1;
temp1 = Alg2_B_i;
temp0 = temp0 * temp1;
dAlg2_B_idt = dAlg2_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg3_s_i;
temp0 = temp0 - temp1;
temp1 = Alg3_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg3_g_i;
temp0 = temp0 * temp1;
temp1 = Alg3_B_i;
temp0 = temp0 * temp1;
dAlg3_B_idt = dAlg3_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg4_s_i;
temp0 = temp0 - temp1;
temp1 = Alg4_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg4_g_i;
temp0 = temp0 * temp1;
temp1 = Alg4_B_i;
temp0 = temp0 * temp1;
dAlg4_B_idt = dAlg4_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg5_s_i;
temp0 = temp0 - temp1;
temp1 = Alg5_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg5_g_i;
temp0 = temp0 * temp1;
temp1 = Alg5_B_i;
temp0 = temp0 * temp1;
dAlg5_B_idt = dAlg5_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg6_s_i;
temp0 = temp0 - temp1;
temp1 = Alg6_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg6_g_i;
temp0 = temp0 * temp1;
temp1 = Alg6_B_i;
temp0 = temp0 * temp1;
dAlg6_B_idt = dAlg6_B_idt + temp0;
dBflat2dt = [ dAlg1_B_idt dAlg2_B_idt dAlg3_B_idt dAlg4_B_idt dAlg5_B_idt dAlg6_B_idt ];
Bflat = Bflat2 + (dBflatdt+dBflat2dt)*dt/2;
Alg1_B_i = Bflat(1);
Alg2_B_i = Bflat(2);
Alg3_B_i = Bflat(3);
Alg4_B_i = Bflat(4);
Alg5_B_i = Bflat(5);
Alg6_B_i = Bflat(6);
      end
   end
Bflat = [ Alg1_B_i Alg2_B_i Alg3_B_i Alg4_B_i Alg5_B_i Alg6_B_i ];
dAlg1_B_idt = 0;
dAlg2_B_idt = 0;
dAlg3_B_idt = 0;
dAlg4_B_idt = 0;
dAlg5_B_idt = 0;
dAlg6_B_idt = 0;
temp0 = 0;
temp1 = Alg1_B_i;
temp0 = temp0 + temp1;
temp1 = Alg2_B_i;
temp0 = temp0 + temp1;
temp1 = Alg3_B_i;
temp0 = temp0 + temp1;
temp1 = Alg4_B_i;
temp0 = temp0 + temp1;
temp1 = Alg5_B_i;
temp0 = temp0 + temp1;
temp1 = Alg6_B_i;
temp0 = temp0 + temp1;
Producer_total = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg1_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg1_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg2_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg2_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg3_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg3_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg4_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg4_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg5_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg5_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg6_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg6_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Alg1_s_i;
temp0 = temp0 - temp1;
temp1 = Alg1_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg1_g_i;
temp0 = temp0 * temp1;
temp1 = Alg1_B_i;
temp0 = temp0 * temp1;
dAlg1_B_idt = dAlg1_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg2_s_i;
temp0 = temp0 - temp1;
temp1 = Alg2_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg2_g_i;
temp0 = temp0 * temp1;
temp1 = Alg2_B_i;
temp0 = temp0 * temp1;
dAlg2_B_idt = dAlg2_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg3_s_i;
temp0 = temp0 - temp1;
temp1 = Alg3_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg3_g_i;
temp0 = temp0 * temp1;
temp1 = Alg3_B_i;
temp0 = temp0 * temp1;
dAlg3_B_idt = dAlg3_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg4_s_i;
temp0 = temp0 - temp1;
temp1 = Alg4_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg4_g_i;
temp0 = temp0 * temp1;
temp1 = Alg4_B_i;
temp0 = temp0 * temp1;
dAlg4_B_idt = dAlg4_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg5_s_i;
temp0 = temp0 - temp1;
temp1 = Alg5_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg5_g_i;
temp0 = temp0 * temp1;
temp1 = Alg5_B_i;
temp0 = temp0 * temp1;
dAlg5_B_idt = dAlg5_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg6_s_i;
temp0 = temp0 - temp1;
temp1 = Alg6_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg6_g_i;
temp0 = temp0 * temp1;
temp1 = Alg6_B_i;
temp0 = temp0 * temp1;
dAlg6_B_idt = dAlg6_B_idt + temp0;
dAlg1_B_idt = 0;
dAlg2_B_idt = 0;
dAlg3_B_idt = 0;
dAlg4_B_idt = 0;
dAlg5_B_idt = 0;
dAlg6_B_idt = 0;
dBflatdt = [ dAlg1_B_idt dAlg2_B_idt dAlg3_B_idt dAlg4_B_idt dAlg5_B_idt dAlg6_B_idt ];
Bflat = Bflat + dBflatdt;
Alg1_B_i = Bflat(1);
Alg2_B_i = Bflat(2);
Alg3_B_i = Bflat(3);
Alg4_B_i = Bflat(4);
Alg5_B_i = Bflat(5);
Alg6_B_i = Bflat(6);
dAlg1_B_idt = 0;
dAlg2_B_idt = 0;
dAlg3_B_idt = 0;
dAlg4_B_idt = 0;
dAlg5_B_idt = 0;
dAlg6_B_idt = 0;
temp0 = 0;
temp1 = Alg1_B_i;
temp0 = temp0 + temp1;
temp1 = Alg2_B_i;
temp0 = temp0 + temp1;
temp1 = Alg3_B_i;
temp0 = temp0 + temp1;
temp1 = Alg4_B_i;
temp0 = temp0 + temp1;
temp1 = Alg5_B_i;
temp0 = temp0 + temp1;
temp1 = Alg6_B_i;
temp0 = temp0 + temp1;
Producer_total = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg1_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg1_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg2_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg2_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg3_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg3_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg4_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg4_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg5_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg5_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Producer_inter;
temp2 = Producer_total;
temp1 = temp1 * temp2;
temp2 = Alg6_B_i;
temp3 = Producer_inter;
temp4 = Producer_intra;
temp3 = temp3 - temp4;
temp2 = temp2 * temp3;
temp1 = temp1 - temp2;
temp2 = Producer_K;
temp1 = temp1 / temp2;
temp0 = temp0 - temp1;
Alg6_g_i = temp0;
temp0 = 1.000000000000000;
temp1 = Alg1_s_i;
temp0 = temp0 - temp1;
temp1 = Alg1_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg1_g_i;
temp0 = temp0 * temp1;
temp1 = Alg1_B_i;
temp0 = temp0 * temp1;
dAlg1_B_idt = dAlg1_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg2_s_i;
temp0 = temp0 - temp1;
temp1 = Alg2_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg2_g_i;
temp0 = temp0 * temp1;
temp1 = Alg2_B_i;
temp0 = temp0 * temp1;
dAlg2_B_idt = dAlg2_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg3_s_i;
temp0 = temp0 - temp1;
temp1 = Alg3_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg3_g_i;
temp0 = temp0 * temp1;
temp1 = Alg3_B_i;
temp0 = temp0 * temp1;
dAlg3_B_idt = dAlg3_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg4_s_i;
temp0 = temp0 - temp1;
temp1 = Alg4_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg4_g_i;
temp0 = temp0 * temp1;
temp1 = Alg4_B_i;
temp0 = temp0 * temp1;
dAlg4_B_idt = dAlg4_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg5_s_i;
temp0 = temp0 - temp1;
temp1 = Alg5_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg5_g_i;
temp0 = temp0 * temp1;
temp1 = Alg5_B_i;
temp0 = temp0 * temp1;
dAlg5_B_idt = dAlg5_B_idt + temp0;
temp0 = 1.000000000000000;
temp1 = Alg6_s_i;
temp0 = temp0 - temp1;
temp1 = Alg6_igr_i;
temp0 = temp0 * temp1;
temp1 = Alg6_g_i;
temp0 = temp0 * temp1;
temp1 = Alg6_B_i;
temp0 = temp0 * temp1;
dAlg6_B_idt = dAlg6_B_idt + temp0;
end
