function clss = h_alpha_cls(H, a)

clss = ones(size(H));

H_l = H <= 0.5;
H_m = H <= 0.9 & ~H_l;
H_h = ~(H_l | H_m);

a_9 = a <= 42.5;
a_8 = a <= 47.5;
a_7 = ~a_8;
a_8 = a_8 & ~a_9;
a_6 = a <= 40;
a_5 = a <= 50;
a_4 = ~a_5;
a_5 = a_5 & ~a_6;
a_2 = a <= 57.5;
a_1 = ~a_2;

clss(a_9 & H_l) = 9;
clss(a_8 & H_l) = 8;
clss(a_7 & H_l) = 7;
clss(a_6 & H_m) = 6;
clss(a_5 & H_m) = 5;
clss(a_4 & H_m) = 4;
clss(a_2 & H_h) = 3;
clss(a_1 & H_h) = 2;

