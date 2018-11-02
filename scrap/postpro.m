% morphological processing
dataset = uavsar;
blank = false(size(dataset.gt));
orders = [7 6 4 5 3 2 1 8 9];
codes = 'gfecdbahi';
for kk = orders;
    close all;
    [a,b] =eval_th(dataset.gt, dataset.output{kk}, dataset.th{kk}(end), true);
%     hgexport(gcf, strcat('fig/palsar/patch/fig9', dataset.names{kk}, '_result.eps'));
    export_fig(strcat('fig10', codes(kk), '.pdf'), '-nocrop', '-opengl', gcf);
end