function wt = getRoi(img)

bw = roipoly(img(:,:,1));
wt = reshape(img(repmat(bw, [1 1 size(img,3)])), [], size(img,3));
wt = mean(wt);