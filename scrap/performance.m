dataset = palsar_patch;
% N_Tar_pix = sum(dataset.gt(:));

for ii = 1:9
    [pd(ii,:), pfa(ii,:)] = eval_th(dataset.gt, dataset.output{ii});
    disp(ii);
end
N_Tar_pix = max(pd(:, end));
pd = pd ./ N_Tar_pix;

%% plot ROC
orders = [7 6 4 5 3 2 1 8 9];
codes = 'gfecdbahi';
names = {'PNF', 'STD', 'PWF', 'TP-Ps', 'OPD', 'DoP', 'RS', 'GWPF\_C', 'GWPF\_EM'};
linewidth = [ones(1,7), 2, 2];
markers = {'o', 'none', 'none', 's', '+', 'x', '^', 'none', 'none'};
linestyles = {'-', '-.',  '--', '--', '--', '--', '--', '-', '-'};
figure; hold on;
for ii = orders
    plot(pfa(ii,:), pd(ii,:), 'LineWidth', linewidth(ii), 'LineStyle', linestyles{ii}, 'Marker', markers{ii})
end
hold off;
grid on;
axis tight;
set(gca, 'XScale', 'log');
xlabel('pfa', 'FontSize', 14);
ylabel('ppd', 'FontSize', 14);
title('Pixel-level ROC of PALSAR dataset', 'FontSize', 14);
legend(names(orders),'Location','northwest', 'FontSize', 12);