function smap = patchSal(img)
% Saliency detection based on distance between patchs in PolSAR images
% input: img    -- input image to be detected
% output: smap   -- saliency map indicated target of interest
[Nx, Ny, Nc] = size(img);

sizeP = 10:10:50;

GSmap = zeros(Nx, Ny); LSmap = GSmap;
for jj = sizeP
    A = multiLook(img, jj, 'distinct');
    [Nxp, Nyp, Nc] = size(A);
    Np = Nxp * Nyp;
    A = reshape(A, [], Nc);
% -------该步骤导致内存不足----

%     Alldist = zeros(Np,Np);
%     for ii = 1:Np-1
%         for jj = ii+1:Np
%             Alldist(ii,jj) = bartlettDist(A(:,ii), A(:,jj));
%             Alldist(jj,ii) = Alldist(ii,jj);
%         end
%     end
% 
%     [~, minMp] = minDist(Alldist, 0.2);
%     Mpdist = Alldist(minMp, minMp);
%     [~,minKp] = minDist(Mpdist, 0.5);
%     Kp = A(:, minMap(minKp));
%     disp(K);
%     GSA = Alldist(minMap(minKp),:);
%    
%-------以下步骤计算较慢，但满足内存条件----
    Alldist = o2oDist(A);
    [~, minMp] = sort(Alldist);
    M = floor(Np/5);
    Mp = A(minMp(1:M),:);
    Mpdist = o2oDist(Mp);
    [~, minKp] = sort(Mpdist);
    K = floor(Np/10);
    Kp = Mp(minKp(1:K),:);
%--------gloabl saliency array
    GSA = zeros(Np, 1);
    for ii = 1:Np
        for kk = 1:K
            GSA(ii) = GSA(ii) + bartlettDist(A(ii,:), Kp(kk,:));
        end
    end
    GSA = GSA / K;
    ratio = min(sizeP) / jj;
    GSA = col2im(repmat(GSA', [jj * jj, 1]), [jj jj], [Nx, Ny],'distinct');
    GSmap = GSmap + GSA * ratio;
    LSA = zeros(Np, 1);
    for ii = 1:Np
        [x, y] = ind2sub([Nxp, Nyp], ii);
        rloc = [x-1, x-1, x-1, x, x, x+1, x+1, x+1];
        cloc = [y-1, y, y+1, y-1, y+1, y-1, y, y+1];
        trueloc = (rloc > 0 & rloc < Nxp) & (cloc > 0 & cloc < Nyp);
        locP = sub2ind([Nxp, Nyp], rloc(trueloc), cloc(trueloc));
        for kk = 1:length(locP)
            LSA(ii) = LSA(ii) + bartlettDist(A(ii,:), A(locP(kk),:));
        end
        LSA(ii) = LSA(ii) / length(locP);
    end
    LSA = col2im(repmat(LSA', [jj * jj, 1]), [jj jj], [Nx, Ny],'distinct');
    LSmap = LSmap + LSA * ratio;
end
smap = GSmap .* LSmap;

function d = bartlettDist(pi, pj)

q = 3;          % dimension of the coherency matrix;
pi = reshape(pi, [q, q]); % reshape to matrix
pj = reshape(pj, [q, q]);

d = log(det(pi + pj)^2/det(pi)/det(pj)) - 2*q*log(2);

function dist = o2oDist(data)
% one to others distance;
Np = size(data, 1);
dist = zeros(Np,1);
h = waitbar(0,'processing');
for ii = 1:Np
    temp = 0;
    for jj = 1:Np
        if ii ~= jj
            temp = temp + bartlettDist(data(ii,:), data(jj,:));
        end
    end
    dist(ii) = temp;
    disp(ii);
    waitbar(ii/Np, h);
end
close(h);

function [minPs, indices] = minDist(distMat, quant)
distP = sum(distMat);
M = quantile(distP, quant);
[minPs, indices] = find(distP < M);