function pdf  = wishart_pdf(T, Sigma)
N=  9; q= 3;

K_N_q = pi^(q * (q-1) / 2);
for i = 1:q
    K_N_q = gamma(N - i + 1);
end

pdf = N^(q * N) * det(T)^(N - q) * exp(-N * trace(Sigma\ T)) / (K_N_q * det(Sigma) ^ N);

