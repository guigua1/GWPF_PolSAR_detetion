function [pd, pfa] = eval_th(gt, img, o_th, show_pic)
blank = false(size(gt));
if nargin > 2
    th = o_th;
else
    th = logspace(-3, 2, 50);
    for ii = 1:length(th)
        th(ii) = biprctile(img(:), th(ii));
    end
    show_pic = false;
end

pfa = zeros(length(th), 1); pd = pfa;

for ii = 1:size(th,2)
    bw_raw = img > th(ii);
    
%% target-level pd
%     bw1 = imclose(bw_raw, strel('disk', 1));
%     TPs = imreconstruct(bw1, gt);
%     [~, n] = bwlabel(TPs, 8);
%     pd(ii) = n;
    
%% pixel-level pd
    TPs = bw_raw & gt;
    pd(ii) = sum(TPs(:));

%% pfa = false alarms
    FPs = bw_raw & ~gt;
    pfa(ii) = sum(FPs(:)) / sum(~gt(:));

    FNs = gt & ~TPs;

    if show_pic
        imshow(img, [min(img(:)), th(ii)]); colormap(gray); hold on;
        imshow(double(cat(3, FPs | FNs *0.2, gt, blank))); alpha(0.75); 
        tp_rgs = regionprops(imdilate(TPs, strel('square', 10)), 'BoundingBox');
        tp_rgs = cat(1, tp_rgs.BoundingBox);
        for jj = 1:size(tp_rgs,1)
            rectangle('Position', tp_rgs(jj,:), 'EdgeColor', 'g', 'Linewidth', 2);
        end
        fp_rgs = regionprops(imdilate(FNs, strel('square', 7)), 'BoundingBox');
        fp_rgs = cat(1, fp_rgs.BoundingBox);
        for jj = 1:size(fp_rgs,1)
            rectangle('Position', fp_rgs(jj,:), 'EdgeColor', 'y', 'Linewidth', 2);
        end
    end
end