% colormap(gray)
% set(gcf, 'Position', [1600 200 400 800])
% set(gca, 'Position', [0 0 1 1])

%% palsar_patch
% axis([600 1088 2400 3800 ])
% axis([175 275 1410 1510]);
% show & save -- small target region.
imshow(img);
axis([175 275 1410 1510]);
export_fig(strcat('fig/palsar/fig14a.pdf'), gcf);

%% small_targets
orders = [7 6 4 5 3 2 1 8 9];
codes = 'gfecdbahi';
dataset = palsar_patch;
% show & save -- corresponding detection masks.
for kk = 8:9;
    figure;
    imagesc(dataset.output{kk}); axis image; colormap(parula);
    axis([85 145 1000 1050]);
    patch([95 100 100 95], [1010 1010 1015 1015], 'w', 'EdgeColor', 'none');
    set(gca, 'Clim', [0 dataset.th{kk}(end)]);
    colorbar; axis off;
    set(gcf, 'Position', [500 500 300 400]);
    export_fig(strcat('fig14', char(codes(kk)+1), '.pdf'), gcf);
end

%% uavsar_patch
% show & save -- azimuth ambiguity region.
imshow(PauliRGB);axis([80 150 2040 2120]);
export_fig(strcat('fig/uavsar/fig15a.pdf'), gcf);

%% azimuth ambiguity
orders = [7 6 4 5 3 2 1 8 9];
codes = 'gfecdbahi';
dataset = uavsar;
% show & save -- corresponding detection masks.
for kk = 8;
    figure;
    imagesc(dataset.output{kk}); axis image; colormap(parula);
    axis([80 150 2040 2120]);
    set(gca, 'Clim', [0, dataset.th{kk}(end)+0.1]);
    colorbar; axis off;
    set(gcf, 'Position', [500 500 500 400]);
    export_fig(strcat('fig15', char(codes(kk)+1), '.pdf'), gcf, '-transparent');
end