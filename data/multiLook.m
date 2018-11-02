function outImg = multiLook(inImg, L, method, norml)

[Nx, Ny, Nc] = size(inImg);

if length(L) == 1;
    L = [L, L];
end
if nargin < 4
    norml = false;
end

switch method
    case 'sliding'
        if Nc == 3
            h = waitbar(0, 'sliding...');
            outImg = zeros(Nx, Ny, Nc^2);
            for ii = 1:Nc
                sImg = conj(inImg(:,:,ii));
                offset = (ii-1) * Nc; 
                for jj = 1:Nc
                    outImg(:,:, offset + jj) = inImg(:,:,jj) .* sImg;
                end
                waitbar(ii/Nc, h, sprintf('processing at %d / %d row...', ii, Nx));
            end
            delete(h);
            Nc = 9;
        end
        parfor ii = 1:Nc
            flt = ones(L)/ L(1) / L(2);
            outImg(:,:,ii) = filter2(flt, inImg(:,:,ii), 'same');
        end
    case 'distinct'
        if Nc == 3
            fun = @(bs) reshape(covm(bs.data), [1 1 9]);
        else
            fun = @(bs) mean(mean(bs.data, 1), 2);
        end
        outImg = blockproc(inImg, [L(1) L(2)], fun);
end
if norml
    outImg = outImg ./ repmat(sqrt(sum(abs(outImg).^2, 3)), [1, 1, Nc]);
end
end

function pcov = covm(pvec)
    pvec = reshape(pvec, [], size(pvec, 3));
    pcov = pvec' * pvec / size(pvec, 1);
end