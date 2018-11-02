function cls = assign_cls(under_cls, centers)

c_log_det = zeros(size(centers, 3));
cls = zeros(size(under_cls, 1), 1);


for jj = 1:size(centers, 3)
    c_log_det(jj) = log(det(centers(:,:,jj)));
end

for ii = 1:size(under_cls, 1)
    crt_pf = reshape(under_cls(ii, :), 3,3);
    dist_cls = zeros(size(c_log_det));
    for jj = 1:size(centers,3)
        dist_cls(jj) = trace(crt_pf \ centers(:,:, jj)) + c_log_det(jj);
    end
    [~, cls(ii)] = min(dist_cls);
end