function [score, coeff, latent] = myPCA(pF, denoise)

if nargin == 1;
    denoise = false;
end
Nc = size(pF, 2);
if Nc == 9
    [V, D] = eig(reshape(mean(pF), 3, 3));
    [latent, inds] = sort(abs(D([1 5 9])), 'descend');
    coeff = kron(V(:,inds), conj(V(:,inds)));
    if denoise
        V_w_zero = cat(2, V(:, inds(1:end-1)), zeros(3, 1));
        coeff = coeff*kron(V_w_zero, conj(V_w_zero))';
        latent(end) = 0;
    end
    score = pF*coeff;
else
     [coeff, score, latent] = pca(pF);
     if denoise
        score = score(:,1:2)*coeff(:,1:2).' + repmat(mean(pF), size(pF, 1), []);
        latent(end) = 0;
     end
     latent = latent.';
end