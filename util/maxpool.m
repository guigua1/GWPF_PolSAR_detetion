 function cls = maxpool(bs)
 T = tabulate(bs.data(:));
 [~, in] = max(T(:, 2));
 cls = T(in, 1);