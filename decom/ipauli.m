function lex_out = ipauli(img)

lexBasis = [1   1  0;
          0   0  sqrt(2);
          1 -1  0]';
if size(img,2) == 9
    lexBasis = kron(lexBasis, lexBasis) / sqrt(2);
end
lex_out = img * lexBasis / sqrt(2);