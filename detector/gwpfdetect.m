function outImg = gwpfdetect(inImg, method, lc)

addpath('PCAdet');

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
        
        img_iter = pF;
        %% iter-tree
        k = 3;  % PALSAR/EMISAR -- 4; UAVSAR -- 4(6);
        img_map{k} = [];
        imSPAN = polSpan(pF);
        img_map{1} = {imSPAN <= 5};  % PALSAR/EMISAR -- 5;
%         img_map{1} = {true(m*n,1)};
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
%             subplot(2, ceil(N_cls /2), ii); 
%             figure;imagesc(test{ii});
        end
end

SP_CORR_SIZE = 5;  %spatial correlation size, pixels faraway from this distance would be considered irrelated.
se = strel('disk',SP_CORR_SIZE); 
Jaccard_index = zeros(N_cls,N_cls); 
d_test = test;
for ii = 1:N_cls
    d_test{ii} = imdilate(test{ii}, se);
end

wt = zeros(N_cls, Nc); 

for ii = 1:N_cls
    mask = test{ii};
    bw1 = d_test{ii};
    wt(ii,:) = mean(pF(mask(:),:));
    
    for jj = ii+1:N_cls
        bw2 = d_test{jj};
        inter_area = bw2 & bw1;
%         imagesc(double(bw1) + double(bw2)*2);
        Jaccard_index(ii,jj) = sum(inter_area(:)) / sum(sum(bw2 | bw1));
        Jaccard_index(jj,ii) = Jaccard_index(ii,jj);
    end
end

Jaccard_dist= exp(1-2*Jaccard_index);
Jaccard_dist = Jaccard_dist - diag(diag(Jaccard_dist));

pF = transformPF(pF, 96);
wt = transformPF(wt, 96);
wt = wt ./ repmat(sqrt(sum(abs(wt).^2, 2)), 1, 6);

response = abs(pF * wt').^2;

RedR = Jaccard_dist ./ repmat(sum(Jaccard_dist, 1), N_cls, 1);
response = response * RedR.^2 ./ (response+eps);
response = 1./ sqrt(1 + response*16);

NBs_SIZE = 1; % emisar = 1
% NBs_SIZE = 5; %palsar/uavsar = 5
OBs_SIZE = 11; % uavsar/emisar = 11
% OBs_SIZE = 40; % palsar = 40
inner_map = zeros(m,n,N_cls);
outer_map = inner_map;
for ii = 1:N_cls
    tmp = reshape(response(:, ii), m, n);
    inner_map(:,:,ii) = conv2(tmp, ones(NBs_SIZE),'same');
    outer_map(:,:,ii) = conv2(reshape(response(:, ii), m, n), ones(OBs_SIZE),'same');
end

inner_map = inner_map ./ repmat(sum(inner_map, 3), 1, 1, N_cls);
% residual = repmat(max(tmp, [], 2), 1, N_cls) - tmp;
% result1= sum(((inner_map) / Jaccard_dist) .* inner_map, 2);

outer_map = outer_map ./ repmat(sum(outer_map, 3), 1, 1, N_cls);
% residual = repmat(max(tmp, [], 2), 1, N_cls) - tmp;
sal_map = sum(reshape((reshape(outer_map, [], N_cls) / Jaccard_dist), m, n, N_cls) .* inner_map, 3);

if lc
    log_flt = fspecial('log', [40, 40]);
    outImg = abs(imfilter(sal_map, log_flt, 'symmetric', 'same')) .* sal_map.^2;
else
    outImg = sal_map;
end
outImg = outImg / max(outImg(:));
% SpatialSaliency = result / curV;

% img_out = sqrt(SpatialSaliency).*imSPAN;

% conSal = contrastSal(img_out, 40);

%% figure index maps;
% figure;
% for ii = 1:N_cls
%     im_2_show = reshape(tmp(:,:,ii), m, n);
%     subplot(2,ceil(N_cls/2),ii);imagesc(im_2_show);title(['Index: ', num2str(ii)]);axis off;
% end
% 
% 
% %% figure summation maps;
% figure; sum_map = zeros(m,n);
% for ii = 1:N_cls
%     figure; imshow(imtophat(test{ii},strel('disk', 10)));colormap('gray');
%     sum_map = sum_map + double(imclose(test{ii},strel('disk', 10)));
% end

%% figure results;
% figure; subplot(2,2,1); set(gcf,'Position', [0 0 1000 800]);
% h = hist(imSpan(:),numBins);
% h = h/m/n;
% lr = linspace(min(imSpan(:)), max(imSpan(:)), numBins);
% bar(lr, h); axis tight;
% title('Histogram in SPAN image of PolSAR','Interpreter','latex','FontSize',12);
% xlabel('Pixel intensity','Interpreter','latex','FontSize',12); 
% ylabel('Frequency','Interpreter','latex','FontSize',12);
% set(gca,'FontName','Times New Roman','FontSize',12);
% subplot(2,2,2);
% h = hist(pcScore,numBins);
% h = h/m/n;
% lr = linspace(min(pcScore(:)), max(pcScore(:)), numBins);
% bar(lr, h); axis tight;
% title('Histogram in $$\emph{1st}$$ principle component','Interpreter','latex','FontSize',12)
% xlabel('Pixel value','Interpreter','latex','FontSize',12); 
% ylabel('Frequency','Interpreter','latex','FontSize',12);
% set(gca,'FontName','Times New Roman','FontSize',12);
% subplot(2,2,3);
% h = hist(score(:,2),numBins);
% h = h/m/n;
% lr = linspace(min(min(score(:,2))), max(max(score(:,2))), numBins);
% bar(lr, h); axis tight;
% title('Histogram in $$\emph{2nd}$$ principle component','Interpreter','latex','FontSize',12)
% xlabel('Pixel value','Interpreter','latex','FontSize',12); 
% ylabel('Frequency','Interpreter','latex','FontSize',12);
% set(gca,'FontName','Times New Roman','FontSize',12);
% subplot(2,2,4);
% h = hist(score(:,3),numBins);
% h = h/m/n;
% lr = linspace(min(min(score(:,3))), max(max(score(:,3))), numBins);
% bar(lr, h); axis tight;
% title('Histogram in $$\emph{3rd}$$ principle component','Interpreter','latex','FontSize',12)
% xlabel('Pixel value','Interpreter','latex','FontSize',12); 
% ylabel('Frequency','Interpreter','latex','FontSize',12);
% set(gca,'FontName','Times New Roman','FontSize',12);