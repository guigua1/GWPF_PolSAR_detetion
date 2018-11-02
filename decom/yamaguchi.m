function [Ps, Pd, Pc, Pv, TP] = yamaguchi(C)
%% yamaguchi decomposition

TP = sum(C(:, [1 5 9]), 2);
Ps = zeros(size(TP)); Pd = Ps; Pv = Pd;

try
	load T.mat T;
catch
    T = pauli(C); 
end

Pc = 2*abs(imag(T(:,8)));
t = 10*log10(C(:,9)./C(:,1));
ind_o= t < -2 | t > 2;
n = length(ind_o);

% h = waitbar(0, 'sliding...');
for i = 1:n
    
    if ind_o(i)
        Pv_temp = 3.75*C(i,5) - 1.875*Pc(i);
        
        if Pv_temp <= 0 && Pc(i) == 0
            [Ps(i), Pd(i), Pv(i)] = FreemanDurden(C(i,:));
%             waitbar(i/n, h, sprintf('processing at %d / %d row...', i, n));
            continue;
        else
            fs = T(i,1)- 0.5*Pv_temp;
            fd = T(i,5) - 0.875*C(i,5) - 0.0625*Pc(i);
            if t(i) < -2
                fc = T(i,4) - 1*Pv_temp/6;
            else
                fc = T(i,4) + 1*Pv_temp/6;
            end
        end
    else
        Pv_temp = 4*C(i,5) - 2*Pc(i);

        if Pv_temp <= 0 && Pc(i) == 0
            [Ps(i), Pd(i), Pv(i)] = FreemanDurden(C(i,:));
%             waitbar(i/n, h, sprintf('processing at %d / %d row...', i, n));
            continue;
        else
            fs = T(i,1) - 2*Pv_temp + Pc(i);
            fd = T(i,5) - C(i,5);
            fc = T(i,4);
        end
    end
    if Pv_temp + Pc(i) < TP(i)
        C0 = C(i,7) - 0.5*C(i,5) + 0.5*Pc(i);
        fc  = abs(fc)^2;
        if real(C0) < 0 
            % double 
            Ps(i) = fs - fc/fd;
            Pd(i) = fd + fc/fd;
        else
            % surface
            Ps(i) = fs + fc/fs;
            Pd(i) = fd - fc/fs;
        end
    else
        Pv(i) = TP(i) - Pc(i);
    end
    
    if Ps(i) > 0
        if Pd(i) > 0
            TP(i) = Ps(i) + Pd(i) + Pv(i) + Pc(i);
        else
            Pd(i) = 0;
            Ps(i) = TP(i) - Pv(i) - Pc(i);
        end
    else
        if Pd(i) > 0
            Ps(i) = 0;
            Pd(i)  = TP(i) - Pv(i) - Pc(i);
        end
    end
%     waitbar(i/n, h, sprintf('processing at %d / %d row...', i, n));
end
% delete(h);
