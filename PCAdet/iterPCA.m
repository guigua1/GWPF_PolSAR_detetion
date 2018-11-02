function img_newmap = iterPCA(img_iter, img_map)
numBins = 256;
k = 3;

img_newmap = cell(length(img_map)*k,1);

for ii = 1:length(img_map)
    ind = img_map{ii};
    if sum(ind) < length(img_iter) / 32
        continue;
    end
    
    img_child = img_iter(ind,:);
    
    [score, ~, latent] = myPCA(img_child);

    disp(['component: ', num2str((ii-1)*k +(1:k))]);
    disp(['eigenvalue: ', num2str(latent)]);
    
%     [latent, inds] = sort(latent, 'descend');
%     o_inds = [1 5 9];
%     n_inds = o_inds(inds);
%     pre-pruning
    if latent(2) < 0.001
        if latent(1) / latent(2) > 10 || latent(1) / latent(2) < 2
            continue;
        end
    end
    
    pcScore = abs(score(:, 1));
    %% GMM iterations
    xx = linspace(min(pcScore), max(pcScore), numBins);
%     interv = xx(2) - xx(1);
    h = hist(pcScore, numBins);
    h = h/length(pcScore);
    cHist = censorHist(h);
    [~, xx_n0] = find(cHist ~= 0);
    xx_n0 = minmax(xx_n0);
    xx = xx(xx_n0(1):xx_n0(2));
    cHist = cHist(xx_n0(1):xx_n0(2));
%     xx_new = linspace(xx(1)-interv*numBins/8, xx(end)+interv*numBins/8, numBins);
%     cHist = interp1(xx, cHist, xx_new, 'pchip');
    cHist(cHist < 0) = 0;
    cHist = cHist / sum(cHist);

%     [mu, theta, p_prior, p_post] = histGMM(cHist',k);
    [~,~,~, p_post] = histGMM(cHist',k);
    
%     max_cls = max(p_post, [], 2);
%     pca_map = p_post == repmat(max_cls, 1,k);
    pca_map = splitGMM(pcScore, p_post, xx);%.*repmat(p_prior(end,:), [size(p_post,1) 1]), xx);
    if isempty(pca_map)
        continue;
    end
    for kk = 1:k
        tmp = ind;
        tmp(ind) = pca_map(:,kk);
        img_newmap{(ii-1)*k+kk} = tmp;
    end
end