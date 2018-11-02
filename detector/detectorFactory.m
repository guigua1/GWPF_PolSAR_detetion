function outImg = detectorFactory(inImg, method, varargin)

[m,n,Nc] = size(inImg);
inBox = [5, 5];

varargin = varargin{1};

switch method(1:2)
    case 'pn'
        outImg = pnfdetect(inImg, method, varargin{:});
    case 'st'
        outImg = pnfdetect(inImg, method, varargin{:});
    case 'pt'
        outImg = pnfdetect(inImg, method, varargin{:});
    case 'pw'
        outImg = pwfdetect(inImg, varargin{:});
    case 'rs'
        if Nc == 3
            outImg = inImg(:,:,1) .* conj(inImg(:,:,2));
            outImg = abs(colfilt(outImg, inBox, 'sliding', @mean));
        elseif Nc == 9
            outImg = abs(inImg(:,:,4));
        end
        
        if varargin{1}
            outImg = cfar(outImg, varargin{2:end});
        end
        
    case 'du'
    %% CTLR decomposition
        inImg = reshape(inImg, [], Nc);
        if Nc == 9
            g0 = sum(inImg(:, [1 5 9]), 2);
            g1 = real(inImg(:, 1) - inImg(:, 9));
            EHV = sqrt(2)*(inImg(:, 4) + inImg(:, 8)) + 1i*(2* inImg(:, 7) - inImg(:, 5));
            g2 = real(EHV);
            g3 = -imag(EHV);
        else
            if Nc == 3
                ECTLR = transformPF(inImg, [34, 42]);
            elseif Nc == 4
                ECTLR = transformPF(inImg, 42);
            end
            ERH = ECTLR(:,1); ERV = ECTLR(:,2);
            k1 = reshape(ERH.*conj(ERH), m, n);
            k2 = reshape(ERV.*conj(ERV), m, n);
            k3 = reshape(ERH.*conj(ERV), m, n);

            k1 = colfilt(k1, inBox, 'sliding', @mean);
            k2 = colfilt(k2, inBox, 'sliding', @mean);
            k3 = colfilt(k3, inBox, 'sliding', @mean);
            g0 = k1 + k2;
            g1 = k1 - k2;
            g2 = 2*real(k3);
            g3 = -2*imag(k3);
        end
        
        doP = sqrt(g1.^2 + g2.^2 + g3.^2)./(g0 + eps);
        if size(doP, 2) == 1
            doP = reshape(doP, m, n);
        end
        
        if strcmp(method(4:end), 'dop')
            outImg = 1-doP;
        elseif strcmp(method(4:end), 'ms')
            rPh = -atan(g3./g2);
            VG = sqrt(g0.*(1-doP));
            I = VG.*cos(rPh/2);
            MS = idct2(sign(dct(I)));
            gf = fspecial('gaussian', inBox);
            outImg = filter2(gf, MS, 'same');
        end
        
        if varargin{1}
            outImg = cfar(outImg, varargin{2:end});
        end
        
    case 'qu'
        %% inCoherent matrix decomposition
        if strcmp(method(4:end), 'tpps')
            try
                load Yamaguchi.mat ym;
                Ps = ym(:,:,3); TP = sum(ym, 3);
            catch
                disp('parameters did not exist.');
            end
            
            if ~exist('ym', 'var')
                if Nc == 3
                    inImg = multiLook(inImg, inBox, 'sliding');
                    Nc = 9;
                end
                [Ps, ~, ~, ~, TP] = yamaguchi(reshape(inImg, [], Nc));
                Ps = reshape(Ps, m, n);
                TP = reshape(TP, m, n);
            end
            
            outImg = real(TP-Ps);
            
        elseif strcmp(method(4:end), 'opd')
            C = reshape(inImg, [], Nc);
            ef = C(:,4) + C(:,6);
            hi = C(:,8) + C(:,9);
            theta = atan(hi ./ ef);
            
            outImg = abs(ef.*cos(theta).^2 + hi.*sin(2*theta)/2);
            outImg = reshape(outImg, m, n);
            outImg(isnan(outImg)) = 0;
        end
        
        if varargin{1}
            outImg = cfar(outImg, varargin{2:end});
        end
        
    case 'gw'
        outImg = gwpfdetect(inImg, varargin{:});
end
%% detection based on Pt-Ps image
% [r1, r2, r3] = cfar(imgPt_Ps);
% imwrite(r3, 'fig\png\detection_result_of_PtPs_image.png');
% %% detection based on optimized Pd image
% [r1, r2, r3] = cfar(imgPd);
% imwrite(r3, 'fig\png\detection_result_of_optimized_Pd_image.png');
