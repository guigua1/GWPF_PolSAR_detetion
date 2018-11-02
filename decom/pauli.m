function pauli_out=pauli(img)

Pbasis = [1   1  0;
          0   0  sqrt(2);
          1  -1  0];
if size(img,2) == 9
    Pbasis = kron(Pbasis, Pbasis) / sqrt(2);
end
pauli_out = img * Pbasis / sqrt(2);