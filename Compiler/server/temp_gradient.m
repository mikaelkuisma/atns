function dBdt = temp_gradient(B)
MODULE_stepsperday = 10.0000000000000000;
Producer_intra = 2.0000000000000000;
Producer_inter = 1.0000000000000000;
Producer_K = 5400.0000000000000000;
Alg1_B_i = 2000.0000000000000000;
Alg2_B_i = 3000.0000000000000000;
Alg1_igr_i = 1.0000000000000000;
Alg1_s_i = 0.2000000000000000;
Alg1_g_i = 0.0000000000000000;
Alg2_igr_i = 1.2000000000000000;
Alg2_s_i = 0.2000000000000000;
Alg2_g_i = 0.0000000000000000;
Consumer_fa = 0.4000000000000000;
Consumer_fm = 0.1000000000000000;
Con1_B_i = 1000.0000000000000000;
Con1_mbr_i = 0.4000000000000000;
Con1_effectiveprey_i = 0.0000000000000000;
Feeding_link1_e_ij = 0.5000000000000000;
Feeding_link1_q_ij = 1.2000000000000000;
Feeding_link1_B0_ij = 1000.0000000000000000;
Feeding_link1_d_ij = 1.0000000000000000;
Feeding_link2_e_ij = 0.5000000000000000;
Feeding_link2_q_ij = 1.2000000000000000;
Feeding_link2_B0_ij = 1000.0000000000000000;
Feeding_link2_d_ij = 1.0000000000000000;
Alg1_B_i = B(1);
Alg2_B_i = B(2);
Con1_B_i = B(3);
dAlg1_B_idt = 0;
dAlg2_B_idt = 0;
dCon1_B_idt = 0;
% 04ee RET 
% 04ef RET 
% 02e3 SUM_LOOP 1
temp0 = 0;
% 02e8 LOAD_INDEXED_DYNAMIC 1
temp1 = Alg1_B_i;
% 02ed SUM_JUMP 739
temp0 = temp0 + temp1;
% 02e8 LOAD_INDEXED_DYNAMIC 1
temp1 = Alg2_B_i;
% 02ed SUM_JUMP 739
temp0 = temp0 + temp1;
% 02f0 STORE_PARAMETER 4
Producer_total = temp0;
% 02f2 INDEX_LOOP 1
% 02f4 LOAD_CONSTANT_8 2
temp0 = 1.000000000000000;
% 02f7 LOAD_PARAMETER 2
temp1 = Producer_inter;
% 02fa LOAD_PARAMETER 4
temp2 = Producer_total;
% 02fb MUL_OPERATOR 
temp1 = temp1 * temp2;
% 0300 LOAD_INDEXED_DYNAMIC 1
temp2 = Alg1_B_i;
% 0303 LOAD_PARAMETER 1
temp3 = Producer_intra;
% 0306 LOAD_PARAMETER 2
temp4 = Producer_inter;
% 0307 SUB_OPERATOR 
temp3 = temp3 - temp4;
% 0308 MUL_OPERATOR 
temp2 = temp2 * temp3;
% 0309 ADD_OPERATOR 
temp1 = temp1 + temp2;
% 030c LOAD_PARAMETER 3
temp2 = Producer_K;
% 030d DIV_OPERATOR 
temp1 = temp1 / temp2;
% 030e SUB_OPERATOR 
temp0 = temp0 - temp1;
% 0313 STORE_INDEXED_PARAMETER 3
Alg1_g_i = temp0;
% 0318 INDEX_JUMP 754
% 02f4 LOAD_CONSTANT_8 2
temp0 = 1.000000000000000;
% 02f7 LOAD_PARAMETER 2
temp1 = Producer_inter;
% 02fa LOAD_PARAMETER 4
temp2 = Producer_total;
% 02fb MUL_OPERATOR 
temp1 = temp1 * temp2;
% 0300 LOAD_INDEXED_DYNAMIC 1
temp2 = Alg2_B_i;
% 0303 LOAD_PARAMETER 1
temp3 = Producer_intra;
% 0306 LOAD_PARAMETER 2
temp4 = Producer_inter;
% 0307 SUB_OPERATOR 
temp3 = temp3 - temp4;
% 0308 MUL_OPERATOR 
temp2 = temp2 * temp3;
% 0309 ADD_OPERATOR 
temp1 = temp1 + temp2;
% 030c LOAD_PARAMETER 3
temp2 = Producer_K;
% 030d DIV_OPERATOR 
temp1 = temp1 / temp2;
% 030e SUB_OPERATOR 
temp0 = temp0 - temp1;
% 0313 STORE_INDEXED_PARAMETER 3
Alg2_g_i = temp0;
% 0318 INDEX_JUMP 754
% 0319 RET 
% 031b INDEX_LOOP 1
% 031d LOAD_CONSTANT_8 2
temp0 = 1.000000000000000;
% 0322 LOAD_INDEXED_PARAMETER 2
temp1 = Alg1_s_i;
% 0323 SUB_OPERATOR 
temp0 = temp0 - temp1;
% 0328 LOAD_INDEXED_PARAMETER 1
temp1 = Alg1_igr_i;
% 0329 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 032e LOAD_INDEXED_PARAMETER 3
temp1 = Alg1_g_i;
% 032f MUL_OPERATOR 
temp0 = temp0 * temp1;
% 0334 LOAD_INDEXED_DYNAMIC 1
temp1 = Alg1_B_i;
% 0335 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 033a STORE_INDEXED_GRADIENT 1
dAlg1_B_idt = dAlg1_B_idt + temp0;
% 033f INDEX_JUMP 795
% 031d LOAD_CONSTANT_8 2
temp0 = 1.000000000000000;
% 0322 LOAD_INDEXED_PARAMETER 2
temp1 = Alg2_s_i;
% 0323 SUB_OPERATOR 
temp0 = temp0 - temp1;
% 0328 LOAD_INDEXED_PARAMETER 1
temp1 = Alg2_igr_i;
% 0329 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 032e LOAD_INDEXED_PARAMETER 3
temp1 = Alg2_g_i;
% 032f MUL_OPERATOR 
temp0 = temp0 * temp1;
% 0334 LOAD_INDEXED_DYNAMIC 1
temp1 = Alg2_B_i;
% 0335 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 033a STORE_INDEXED_GRADIENT 1
dAlg2_B_idt = dAlg2_B_idt + temp0;
% 033f INDEX_JUMP 795
% 0340 RET 
% 034d RET 
% 034f INDEX_LOOP 1
% 0352 LOAD_PARAMETER 1
temp0 = Consumer_fa;
% 0357 LOAD_INDEXED_PARAMETER 1
temp1 = Con1_mbr_i;
% 0358 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 035d LOAD_INDEXED_DYNAMIC 1
temp1 = Con1_B_i;
% 035e MUL_OPERATOR 
temp0 = temp0 * temp1;
% 035f UNARY_MINUS 
temp0 = -temp0;
% 0364 STORE_INDEXED_GRADIENT 1
dCon1_B_idt = dCon1_B_idt + temp0;
% 0369 INDEX_JUMP 847
% 036a RET 
% 036d LINK_LOOP 
% 036f LOAD_CONSTANT_8 4
temp0 = 0.000000000000000;
% 0374 STORE_PARAMETER_BY_IDX_1 2
Con1_effectiveprey_i = temp0;
% 0379 LINK_JUMP 877
% 036f LOAD_CONSTANT_8 4
temp0 = 0.000000000000000;
% 0374 STORE_PARAMETER_BY_IDX_1 2
Con1_effectiveprey_i = temp0;
% 0379 LINK_JUMP 877
% 037a LINK_LOOP 
% 037f LOAD_DYNAMIC_BY_IDX_2 1
temp0 = Alg1_B_i;
% 0384 LOAD_LINK_INDEXED_PARAMETER 2
temp1 = Feeding_link1_q_ij;
% 0385 POW_OPERATOR 
temp0 = temp0 ^ temp1;
% 038a ADD_PARAMETER_BY_IDX_1 2
Con1_effectiveprey_i = Con1_effectiveprey_i + temp0;
% 038f LINK_JUMP 890
% 037f LOAD_DYNAMIC_BY_IDX_2 1
temp0 = Alg2_B_i;
% 0384 LOAD_LINK_INDEXED_PARAMETER 2
temp1 = Feeding_link2_q_ij;
% 0385 POW_OPERATOR 
temp0 = temp0 ^ temp1;
% 038a ADD_PARAMETER_BY_IDX_1 2
Con1_effectiveprey_i = Con1_effectiveprey_i + temp0;
% 038f LINK_JUMP 890
% 0390 LINK_LOOP 
% 0395 LOAD_DYNAMIC_BY_IDX_2 1
temp0 = Alg1_B_i;
% 039a LOAD_LINK_INDEXED_PARAMETER 2
temp1 = Feeding_link1_q_ij;
% 039b POW_OPERATOR 
temp0 = temp0 ^ temp1;
% 03a0 LOAD_LINK_INDEXED_PARAMETER 3
temp1 = Feeding_link1_B0_ij;
% 03a5 LOAD_LINK_INDEXED_PARAMETER 2
temp2 = Feeding_link1_q_ij;
% 03a6 POW_OPERATOR 
temp1 = temp1 ^ temp2;
% 03ab LOAD_PARAMETER_BY_IDX_1 2
temp2 = Con1_effectiveprey_i;
% 03ac ADD_OPERATOR 
temp1 = temp1 + temp2;
% 03ad DIV_OPERATOR 
temp0 = temp0 / temp1;
% 03b2 STORE_LINK_INDEXED_PARAMETER 5
Feeding_link1_F_ij = temp0;
% 03b7 LINK_JUMP 912
% 0395 LOAD_DYNAMIC_BY_IDX_2 1
temp0 = Alg2_B_i;
% 039a LOAD_LINK_INDEXED_PARAMETER 2
temp1 = Feeding_link2_q_ij;
% 039b POW_OPERATOR 
temp0 = temp0 ^ temp1;
% 03a0 LOAD_LINK_INDEXED_PARAMETER 3
temp1 = Feeding_link2_B0_ij;
% 03a5 LOAD_LINK_INDEXED_PARAMETER 2
temp2 = Feeding_link2_q_ij;
% 03a6 POW_OPERATOR 
temp1 = temp1 ^ temp2;
% 03ab LOAD_PARAMETER_BY_IDX_1 2
temp2 = Con1_effectiveprey_i;
% 03ac ADD_OPERATOR 
temp1 = temp1 + temp2;
% 03ad DIV_OPERATOR 
temp0 = temp0 / temp1;
% 03b2 STORE_LINK_INDEXED_PARAMETER 5
Feeding_link2_F_ij = temp0;
% 03b7 LINK_JUMP 912
% 03b8 LINK_LOOP 
% 03bd LOAD_PARAMETER_BY_IDX_1 1
temp0 = Con1_mbr_i;
% 03c2 LOAD_LINK_INDEXED_PARAMETER 5
temp1 = Feeding_link1_F_ij;
% 03c3 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 03c8 LOAD_DYNAMIC_BY_IDX_1 1
temp1 = Con1_B_i;
% 03c9 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 03ce STORE_LINK_INDEXED_PARAMETER 6
Feeding_link1_feedingrate_ij = temp0;
% 03d3 LINK_JUMP 952
% 03bd LOAD_PARAMETER_BY_IDX_1 1
temp0 = Con1_mbr_i;
% 03c2 LOAD_LINK_INDEXED_PARAMETER 5
temp1 = Feeding_link2_F_ij;
% 03c3 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 03c8 LOAD_DYNAMIC_BY_IDX_1 1
temp1 = Con1_B_i;
% 03c9 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 03ce STORE_LINK_INDEXED_PARAMETER 6
Feeding_link2_feedingrate_ij = temp0;
% 03d3 LINK_JUMP 952
% 03d4 RET 
% 03d5 LINK_LOOP 
% 03da LOAD_LINK_INDEXED_PARAMETER 6
temp0 = Feeding_link1_feedingrate_ij;
% 03df STORE_GRADIENT_BY_IDX_1 1
dCon1_B_idt = dCon1_B_idt + temp0;
% 03e4 LINK_JUMP 981
% 03da LOAD_LINK_INDEXED_PARAMETER 6
temp0 = Feeding_link2_feedingrate_ij;
% 03df STORE_GRADIENT_BY_IDX_1 1
dCon1_B_idt = dCon1_B_idt + temp0;
% 03e4 LINK_JUMP 981
% 03e5 LINK_LOOP 
% 03ea LOAD_LINK_INDEXED_PARAMETER 6
temp0 = Feeding_link1_feedingrate_ij;
% 03ef LOAD_LINK_INDEXED_PARAMETER 1
temp1 = Feeding_link1_e_ij;
% 03f0 DIV_OPERATOR 
temp0 = temp0 / temp1;
% 03f1 UNARY_MINUS 
temp0 = -temp0;
% 03f6 STORE_GRADIENT_BY_IDX_2 1
dAlg1_B_idt = dAlg1_B_idt + temp0;
% 03fb LINK_JUMP 997
% 03ea LOAD_LINK_INDEXED_PARAMETER 6
temp0 = Feeding_link2_feedingrate_ij;
% 03ef LOAD_LINK_INDEXED_PARAMETER 1
temp1 = Feeding_link2_e_ij;
% 03f0 DIV_OPERATOR 
temp0 = temp0 / temp1;
% 03f1 UNARY_MINUS 
temp0 = -temp0;
% 03f6 STORE_GRADIENT_BY_IDX_2 1
dAlg2_B_idt = dAlg2_B_idt + temp0;
% 03fb LINK_JUMP 997
% 03fc RET 
dAlg1_B_idt = 0;
dAlg2_B_idt = 0;
dCon1_B_idt = 0;
% 04ee RET 
% 04ef RET 
% 02e3 SUM_LOOP 1
temp0 = 0;
% 02e8 LOAD_INDEXED_DYNAMIC 1
temp1 = Alg1_B_i;
% 02ed SUM_JUMP 739
temp0 = temp0 + temp1;
% 02e8 LOAD_INDEXED_DYNAMIC 1
temp1 = Alg2_B_i;
% 02ed SUM_JUMP 739
temp0 = temp0 + temp1;
% 02f0 STORE_PARAMETER 4
Producer_total = temp0;
% 02f2 INDEX_LOOP 1
% 02f4 LOAD_CONSTANT_8 2
temp0 = 1.000000000000000;
% 02f7 LOAD_PARAMETER 2
temp1 = Producer_inter;
% 02fa LOAD_PARAMETER 4
temp2 = Producer_total;
% 02fb MUL_OPERATOR 
temp1 = temp1 * temp2;
% 0300 LOAD_INDEXED_DYNAMIC 1
temp2 = Alg1_B_i;
% 0303 LOAD_PARAMETER 1
temp3 = Producer_intra;
% 0306 LOAD_PARAMETER 2
temp4 = Producer_inter;
% 0307 SUB_OPERATOR 
temp3 = temp3 - temp4;
% 0308 MUL_OPERATOR 
temp2 = temp2 * temp3;
% 0309 ADD_OPERATOR 
temp1 = temp1 + temp2;
% 030c LOAD_PARAMETER 3
temp2 = Producer_K;
% 030d DIV_OPERATOR 
temp1 = temp1 / temp2;
% 030e SUB_OPERATOR 
temp0 = temp0 - temp1;
% 0313 STORE_INDEXED_PARAMETER 3
Alg1_g_i = temp0;
% 0318 INDEX_JUMP 754
% 02f4 LOAD_CONSTANT_8 2
temp0 = 1.000000000000000;
% 02f7 LOAD_PARAMETER 2
temp1 = Producer_inter;
% 02fa LOAD_PARAMETER 4
temp2 = Producer_total;
% 02fb MUL_OPERATOR 
temp1 = temp1 * temp2;
% 0300 LOAD_INDEXED_DYNAMIC 1
temp2 = Alg2_B_i;
% 0303 LOAD_PARAMETER 1
temp3 = Producer_intra;
% 0306 LOAD_PARAMETER 2
temp4 = Producer_inter;
% 0307 SUB_OPERATOR 
temp3 = temp3 - temp4;
% 0308 MUL_OPERATOR 
temp2 = temp2 * temp3;
% 0309 ADD_OPERATOR 
temp1 = temp1 + temp2;
% 030c LOAD_PARAMETER 3
temp2 = Producer_K;
% 030d DIV_OPERATOR 
temp1 = temp1 / temp2;
% 030e SUB_OPERATOR 
temp0 = temp0 - temp1;
% 0313 STORE_INDEXED_PARAMETER 3
Alg2_g_i = temp0;
% 0318 INDEX_JUMP 754
% 0319 RET 
% 031b INDEX_LOOP 1
% 031d LOAD_CONSTANT_8 2
temp0 = 1.000000000000000;
% 0322 LOAD_INDEXED_PARAMETER 2
temp1 = Alg1_s_i;
% 0323 SUB_OPERATOR 
temp0 = temp0 - temp1;
% 0328 LOAD_INDEXED_PARAMETER 1
temp1 = Alg1_igr_i;
% 0329 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 032e LOAD_INDEXED_PARAMETER 3
temp1 = Alg1_g_i;
% 032f MUL_OPERATOR 
temp0 = temp0 * temp1;
% 0334 LOAD_INDEXED_DYNAMIC 1
temp1 = Alg1_B_i;
% 0335 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 033a STORE_INDEXED_GRADIENT 1
dAlg1_B_idt = dAlg1_B_idt + temp0;
% 033f INDEX_JUMP 795
% 031d LOAD_CONSTANT_8 2
temp0 = 1.000000000000000;
% 0322 LOAD_INDEXED_PARAMETER 2
temp1 = Alg2_s_i;
% 0323 SUB_OPERATOR 
temp0 = temp0 - temp1;
% 0328 LOAD_INDEXED_PARAMETER 1
temp1 = Alg2_igr_i;
% 0329 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 032e LOAD_INDEXED_PARAMETER 3
temp1 = Alg2_g_i;
% 032f MUL_OPERATOR 
temp0 = temp0 * temp1;
% 0334 LOAD_INDEXED_DYNAMIC 1
temp1 = Alg2_B_i;
% 0335 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 033a STORE_INDEXED_GRADIENT 1
dAlg2_B_idt = dAlg2_B_idt + temp0;
% 033f INDEX_JUMP 795
% 0340 RET 
% 034d RET 
% 034f INDEX_LOOP 1
% 0352 LOAD_PARAMETER 1
temp0 = Consumer_fa;
% 0357 LOAD_INDEXED_PARAMETER 1
temp1 = Con1_mbr_i;
% 0358 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 035d LOAD_INDEXED_DYNAMIC 1
temp1 = Con1_B_i;
% 035e MUL_OPERATOR 
temp0 = temp0 * temp1;
% 035f UNARY_MINUS 
temp0 = -temp0;
% 0364 STORE_INDEXED_GRADIENT 1
dCon1_B_idt = dCon1_B_idt + temp0;
% 0369 INDEX_JUMP 847
% 036a RET 
% 036d LINK_LOOP 
% 036f LOAD_CONSTANT_8 4
temp0 = 0.000000000000000;
% 0374 STORE_PARAMETER_BY_IDX_1 2
Con1_effectiveprey_i = temp0;
% 0379 LINK_JUMP 877
% 036f LOAD_CONSTANT_8 4
temp0 = 0.000000000000000;
% 0374 STORE_PARAMETER_BY_IDX_1 2
Con1_effectiveprey_i = temp0;
% 0379 LINK_JUMP 877
% 037a LINK_LOOP 
% 037f LOAD_DYNAMIC_BY_IDX_2 1
temp0 = Alg1_B_i;
% 0384 LOAD_LINK_INDEXED_PARAMETER 2
temp1 = Feeding_link1_q_ij;
% 0385 POW_OPERATOR 
temp0 = temp0 ^ temp1;
% 038a ADD_PARAMETER_BY_IDX_1 2
Con1_effectiveprey_i = Con1_effectiveprey_i + temp0;
% 038f LINK_JUMP 890
% 037f LOAD_DYNAMIC_BY_IDX_2 1
temp0 = Alg2_B_i;
% 0384 LOAD_LINK_INDEXED_PARAMETER 2
temp1 = Feeding_link2_q_ij;
% 0385 POW_OPERATOR 
temp0 = temp0 ^ temp1;
% 038a ADD_PARAMETER_BY_IDX_1 2
Con1_effectiveprey_i = Con1_effectiveprey_i + temp0;
% 038f LINK_JUMP 890
% 0390 LINK_LOOP 
% 0395 LOAD_DYNAMIC_BY_IDX_2 1
temp0 = Alg1_B_i;
% 039a LOAD_LINK_INDEXED_PARAMETER 2
temp1 = Feeding_link1_q_ij;
% 039b POW_OPERATOR 
temp0 = temp0 ^ temp1;
% 03a0 LOAD_LINK_INDEXED_PARAMETER 3
temp1 = Feeding_link1_B0_ij;
% 03a5 LOAD_LINK_INDEXED_PARAMETER 2
temp2 = Feeding_link1_q_ij;
% 03a6 POW_OPERATOR 
temp1 = temp1 ^ temp2;
% 03ab LOAD_PARAMETER_BY_IDX_1 2
temp2 = Con1_effectiveprey_i;
% 03ac ADD_OPERATOR 
temp1 = temp1 + temp2;
% 03ad DIV_OPERATOR 
temp0 = temp0 / temp1;
% 03b2 STORE_LINK_INDEXED_PARAMETER 5
Feeding_link1_F_ij = temp0;
% 03b7 LINK_JUMP 912
% 0395 LOAD_DYNAMIC_BY_IDX_2 1
temp0 = Alg2_B_i;
% 039a LOAD_LINK_INDEXED_PARAMETER 2
temp1 = Feeding_link2_q_ij;
% 039b POW_OPERATOR 
temp0 = temp0 ^ temp1;
% 03a0 LOAD_LINK_INDEXED_PARAMETER 3
temp1 = Feeding_link2_B0_ij;
% 03a5 LOAD_LINK_INDEXED_PARAMETER 2
temp2 = Feeding_link2_q_ij;
% 03a6 POW_OPERATOR 
temp1 = temp1 ^ temp2;
% 03ab LOAD_PARAMETER_BY_IDX_1 2
temp2 = Con1_effectiveprey_i;
% 03ac ADD_OPERATOR 
temp1 = temp1 + temp2;
% 03ad DIV_OPERATOR 
temp0 = temp0 / temp1;
% 03b2 STORE_LINK_INDEXED_PARAMETER 5
Feeding_link2_F_ij = temp0;
% 03b7 LINK_JUMP 912
% 03b8 LINK_LOOP 
% 03bd LOAD_PARAMETER_BY_IDX_1 1
temp0 = Con1_mbr_i;
% 03c2 LOAD_LINK_INDEXED_PARAMETER 5
temp1 = Feeding_link1_F_ij;
% 03c3 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 03c8 LOAD_DYNAMIC_BY_IDX_1 1
temp1 = Con1_B_i;
% 03c9 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 03ce STORE_LINK_INDEXED_PARAMETER 6
Feeding_link1_feedingrate_ij = temp0;
% 03d3 LINK_JUMP 952
% 03bd LOAD_PARAMETER_BY_IDX_1 1
temp0 = Con1_mbr_i;
% 03c2 LOAD_LINK_INDEXED_PARAMETER 5
temp1 = Feeding_link2_F_ij;
% 03c3 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 03c8 LOAD_DYNAMIC_BY_IDX_1 1
temp1 = Con1_B_i;
% 03c9 MUL_OPERATOR 
temp0 = temp0 * temp1;
% 03ce STORE_LINK_INDEXED_PARAMETER 6
Feeding_link2_feedingrate_ij = temp0;
% 03d3 LINK_JUMP 952
% 03d4 RET 
% 03d5 LINK_LOOP 
% 03da LOAD_LINK_INDEXED_PARAMETER 6
temp0 = Feeding_link1_feedingrate_ij;
% 03df STORE_GRADIENT_BY_IDX_1 1
dCon1_B_idt = dCon1_B_idt + temp0;
% 03e4 LINK_JUMP 981
% 03da LOAD_LINK_INDEXED_PARAMETER 6
temp0 = Feeding_link2_feedingrate_ij;
% 03df STORE_GRADIENT_BY_IDX_1 1
dCon1_B_idt = dCon1_B_idt + temp0;
% 03e4 LINK_JUMP 981
% 03e5 LINK_LOOP 
% 03ea LOAD_LINK_INDEXED_PARAMETER 6
temp0 = Feeding_link1_feedingrate_ij;
% 03ef LOAD_LINK_INDEXED_PARAMETER 1
temp1 = Feeding_link1_e_ij;
% 03f0 DIV_OPERATOR 
temp0 = temp0 / temp1;
% 03f1 UNARY_MINUS 
temp0 = -temp0;
% 03f6 STORE_GRADIENT_BY_IDX_2 1
dAlg1_B_idt = dAlg1_B_idt + temp0;
% 03fb LINK_JUMP 997
% 03ea LOAD_LINK_INDEXED_PARAMETER 6
temp0 = Feeding_link2_feedingrate_ij;
% 03ef LOAD_LINK_INDEXED_PARAMETER 1
temp1 = Feeding_link2_e_ij;
% 03f0 DIV_OPERATOR 
temp0 = temp0 / temp1;
% 03f1 UNARY_MINUS 
temp0 = -temp0;
% 03f6 STORE_GRADIENT_BY_IDX_2 1
dAlg2_B_idt = dAlg2_B_idt + temp0;
% 03fb LINK_JUMP 997
% 03fc RET 
dBdt = [ dAlg1_B_idt dAlg2_B_idt dCon1_B_idt ];
