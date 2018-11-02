function h = censorHist(h)
%% exclude the outliner value in the histogram

widS = 2;
tmp = zeros(length(h)+2*widS,1);
tmp(widS+1:length(h)+widS) = h;
for ii = 1:length(h)
    h(ii) = median(tmp(ii:ii+2*widS));
end