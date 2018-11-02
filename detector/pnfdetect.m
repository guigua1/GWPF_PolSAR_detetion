function outImg = pnfdetect(inImg, method, wt, rr)
% Polarimetric Notch Filter (PNF) for target detection
% input: img    -- input image to be detected
%           method  -- detector type among 'STD (single target detector),' 'PTD (partial target detector)'
%                   -- and 'PNF (polarimetric notch filter)'
%           wt      -- polarimetric vector of target of interest
%           rr       -- reduced ratio of detector
% output: bw   -- binary map indicated target of interest

% defaults parameters

[Nx, Ny, ~] = size(inImg); 
% preparing data for chosen detection method
if strcmp(method, 'pnf')
    % the two boxes is used in PNF<Marino et al. 2013>.
    inImg = pfv(inImg);
    Nc = 6;
    exBox = [45, 45];
    wt = multiLook(inImg, exBox, 'sliding', true);
    wt = reshape(wt, [], Nc);
elseif strcmp(method, 'ptd')
    inImg = pfv(inImg);
    wt = transformPF(wt, 96);
    Nc = 6;
else
    assert(size(inImg, 3) == 3, 'Input for STD must be polarized vectors with 3 elements');
    Nc = 3;
end

if ~exist('wt', 'var') || isempty(wt)
    wt = mean(reshape(inImg(repmat(roipoly(inImg(:,:,1)), [1 1 Nc])), [], Nc));
end

if size(wt, 1) == 1
    wt = wt / norm(wt);
end

inImg = reshape(inImg, [], Nc);

%% procesing whole image 
P = sum(inImg .* conj(inImg), 2);

if strcmp(method, 'pnf')
    Pnf = sum(inImg .* conj(wt), 2);
    assert(~any(P - abs(Pnf).^2 < 0), 'There exists irregular data!!!!'); 
    outImg = 1./sqrt(1 + rr./(abs(P - abs(Pnf).^2) + eps));
else
    Pt = inImg * wt';
    outImg= 1./sqrt(1 + rr *(P./(abs(Pt).^2 + eps) - 1));
    outImg(isinf(outImg)) = 0;
end
outImg = reshape(outImg, Nx, Ny);

function partial_feature = pfv(inImg)
    [Nx, Ny, Nc] = size(inImg); 
    if Nc == 3
        inBox = [5, 5];
        inImg = multiLook(inImg, inBox, 'sliding');
        Nc =  9;
    end
    if Nc == 9
        inImg = reshape(transformPF(reshape(inImg, [], Nc), 96), Nx, Ny, []);
        Nc = 6;
    end
    assert(Nc == 6, 'The length of partial feature vector must be 6!!!');
    partial_feature = inImg;
