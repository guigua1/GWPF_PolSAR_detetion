function [Ps, Pd, Pv] = FreemanDurden(C)


C = reshape(C, [3, 3]);

ALP = 0;
BET = 0;
CC(2,2) = C(2,2);
CC13_im = imag(C(1,3));
fv = 3 * CC(2,2) / 2;
CC11 = C(1,1) - fv;
CC33 = C(3,3) - fv;
CC13_re = real(C(1,3)) - fv / 3;
if (CC11 <= eps) || (CC33 <= eps)            %Volume Scatter>Total
    fv = 3 * (CC11 + CC(2,2) + CC33 + 2 *fv) /8 ;
    fd = 0;
    fs = 0;
else
    %Data conditioning for non realizable ShhSvv* term
    if ((CC13_re * CC13_re + CC13_im * CC13_im) > CC11 * CC33)
        rtemp = CC13_re * CC13_re + CC13_im * CC13_im;
        CC13_re = CC13_re * sqrt(CC11 * CC33 / rtemp);
        CC13_im = CC13_im * sqrt(CC11 * CC33 / rtemp);
    end
    %Odd Bounce
    if (CC13_re >= 0)
        ALP = -1;
        fd = (CC11 * CC33 - CC13_re * CC13_re - CC13_im * CC13_im) / (CC11 + CC33 + 2 * CC13_re);
        fs = CC33 - fd;
        BET = sqrt((fd + CC13_re) * (fd + CC13_re) + CC13_im * CC13_im) / fs;
    end
    %Even Bounce
    if (CC13_re < 0)
        BET = 1;
        fs = (CC11 * CC33 - CC13_re * CC13_re - CC13_im * CC13_im) / (CC11 + CC33 - 2 * CC13_re);
        fd = CC33 - fs;
        ALP = sqrt((fs - CC13_re) * (fs - CC13_re) + CC13_im * CC13_im) / fd;
    end
end
Pv = 8 / 3 * fv;
Pd = fd *(1 + ALP^2);
Ps = fs *(1 + BET^2);



    
