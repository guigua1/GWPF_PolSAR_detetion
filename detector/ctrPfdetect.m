function outImg = ctrPfdetect(inImg, method, do_ptd)

addpath('PCAdet');

if nargin <= 3
    do_ptd = false;
end

[m,n,Nc] = size(inImg);

pF = reshape(inImg, [m*n Nc]);

switch method
    case 'cloude'
        try 
            load h_a_cls.mat clss;
        catch
            disp('Please provided Cloude decompostion of PolSAR data.');
            return;
        end
        counts = tabulate(clss(:));
        cls = counts(counts(:,2) ~= 0, 1);
        N_cls = length(cls); test = cell(N_cls, 1);
        for ii = 1:N_cls
            test{ii} = clss == cls(ii);
        end
        
    case 'pca'
        %% PCA denoise

        img_iter = pF; % ./ repmat(imSPAN, 1, Nc);

        %% iter-tree

        k = 4;  % PALSAR/EMISAR -- 4; UAVSAR -- 6;
        img_map{k} = [];
        imSPAN = polSpan(pF);
        img_map{1} = {imSPAN<= 5};  % PALSAR/EMISAR -- 5;
        for ii = 2:k
            disp(['level: ',num2str(ii)]);
            img_map{ii} = iterPCA(img_iter, img_map{ii-1});
        end

        test = recursive_map(img_map);
        if sum(~img_map{1}{1}) ~= 0
            test{end+1} = ~img_map{1}{1};
        end
        
        N_cls = length(test);

        for ii = 1:N_cls
            test{ii} = reshape(test{ii}, m, n);
        end
end

SP_CORR_SIZE = 5;  %spatial correlation size, pixels faraway from this distance would be considered irrelated.
se = strel('disk',SP_CORR_SIZE); 
Jaccard_index = zeros(N_cls,N_cls); 

bkg = zeros(N_cls,1);

wt = zeros(N_cls, Nc); 
response = zeros(m * n, N_cls);
for ii = 1:N_cls
    mask = test{ii};
    bw1 = imdilate(mask,se);
    bkg(ii) = sum(bw1(:));
    wt(ii,:) = mean(pF(mask(:),:));
    response(:, ii) = mask(:);
    
    for jj = ii+1:N_cls
        bw2 = imdilate(test{jj}, se);
        inter_area = bw2 & bw1;
%         imagesc(double(bw1) + double(bw2)*2);
        Jaccard_index(ii,jj) = sum(inter_area(:)) ./ bkg(ii);
    end
end

Jaccard_dist= exp(1-Jaccard_index);
Jaccard_dist = Jaccard_dist - diag(diag(Jaccard_dist));

if do_ptd
    pF = transformPF(pF, 96);
    wt = transformPF(wt, 96);
    wt = wt ./ repmat(sqrt(sum(abs(wt).^2, 2)), 1, 6);
    response = abs(pF * wt').^2;
    RedR = Jaccard_dist ./ repmat(sum(Jaccard_dist), N_cls, 1);
    response = response * RedR.^4 ./ (response);
%     response(isinf(response)) = 0;
    response = 1./ sqrt(1 + response*64);
end

NBs_SIZE = 3;
for ii = 1:N_cls
    tmp1 = conv2(reshape(response(:, ii), m, n), ones(NBs_SIZE),'same');
    tmp(:,ii) = tmp1(:);
end

residual =  repmat(max(tmp), m*n, 1) - tmp;
result= sum((residual * Jaccard_index) .* response, 2);

result = result - min(result);
result = result / max(result);
result = reshape(result, m, n);

outImg = result;
