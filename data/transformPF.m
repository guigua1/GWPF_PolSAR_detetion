function pf_t = transformPF(pf, method)

[m,n,Nc] = size(pf);

if Nc ~= 1
    pf = reshape(pf, [], Nc);
end

if length(method)> 1
    for k = 1:length(method)
        pf = transformPF(pf, method(k));
    end
    pf_t = pf;
    return;
end

% monostatic -> bistatic
C34 = [1 0         0         0;
       0 1/sqrt(2) 1/sqrt(2) 0;
       0 0         0         1];
   
% bistatic -> monostatic
C43 = C34';

switch method
    case 43
        pf_t = pf * C43;
    case 34
        pf_t = pf * C34;
    case 99
        C99 = [1  0  0  0  0  0  0  0  0;
                    0 -1i 0 1i 0  0  0  0  0;
                    0  1  0  1  0  0  0  0  0;
                    0  0 -1i 0  0  0 1i 0  0;
                    0  0  1  0  0  0  1  0  0;
                    0  0  0  0  1  0  0  0  0;
                    0  0  0  0  0  -1i 0 1i 0;
                    0  0  0  0  0  1  0  1  0;
                    0  0  0  0  0  0  0  0  1];
        pf_t = pf * C99;
    case 42
        % CTLR mode
        C42 = [ 1  0 ;
                   -1i 0 ;
                    0  1 ;
                    0 -1i]/sqrt(2);
        pf_t = pf * C42;
    case 96
        pf_t = pf(:, [1 5 9 4 7 8]);
end

if Nc ~= 1
    pf_t = reshape(pf_t, m, n, []);
end
