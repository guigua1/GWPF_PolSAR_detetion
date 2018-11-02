function result = run_time(datapath, inImg)

%% test bin files
% files = listDir(datapath, {'bin$'});
% infofile = listDir(datapath, {'ini$'});
% info = readPara(infofile{1});
% 
% img = inputFile(files, info);
% 
% img1 = transformPF(reshape(img,[], 9), 99);
% img1 = reshape(img1, info.height, info.width,[]);
% 
% img2 = multiLook(img1, [4 1], 'distinct');
% imgpauli = pauli(img2);
% imgpauli = abs(imgpauli).^2;
% % img1 = reshape(img1, info.height, info.width, 3);
% % imgpauli = reshape(imgpauli, info.height, info.width, 3);
% 
% displayPf(imgpauli, info, 'lex');
% displayPf(img2, info);

%% test mat files
addpath(datapath);
if nargin == 1
    try
        load('S.mat')
        inImg = S;
    catch
        disp('No S data loaded.');
        try
            load('C.mat');
        catch
            disp('No C data loaded.');
            load('T.mat');
            assert( exist('T', 'var') == 1, 'No T data loaded. \r\nNo any available data in the path!!!!');
            C = reshape(ipauli(reshape(T, [], 9)), size(T, 1), size(T, 2), 9);
        end
        inImg = C;
    end
end

%% time consumption

epoch = 5;
nDetectors = 9;
[Nx, Ny, Nc] = size(inImg);
tmpfile = strcat(datapath, '\result.mat');
try
    load(tmpfile);
catch
    disp('parameters did not exist.');
end

if ~exist('result', 'var') || any(size(result.img) ~= size(inImg))
    result.tm_cost = zeros(epoch+1, nDetectors);
    result.output = cell(nDetectors, 1);
    result.names = {'pnf', 'ptd', 'pwf', 'qu-tpps', 'qu-opd', 'du-dop', 'rs', 'gwpf', 'gwpf'};
    wt = mean(reshape(inImg(repmat(roipoly(inImg(:,:,1)), [1 1 Nc])), [], Nc));
    result.params{2} = {wt, 1};
end

% parameters for PNF
result.params{1} = {[], 2e-1};
% parameters for PTD

posts.densf = 0;
posts.morph = 0;
posts.rad = 3;

% parameters for PWF
result.params{3} = {0, 35, posts};

% parameters for TPPS
result.params{4} = {1, 0, 40, posts};
% parameters for opd
result.params{5} = {1, 0, 40, posts};
% parameters for DOP
result.params{6} = {1, 0, 40, posts};
% parameters for RS
result.params{7} = {1, 0, 40, posts};
% parameters for GPWF-cloude
result.params{8} = {'cloude', true};
% parameters for GPWF-pca
result.params{9} = {'pca', false};

for ii = 1:epoch
    for jj = 8:9
        fprintf('------Processing task %d/%d ... of %d/%d epoch------\n', jj, nDetectors, ii, epoch);
        start_t = cputime;
        result.output{jj} = detectorFactory(inImg, result.names{jj}, result.params{jj});
        result.tm_cost(ii,jj) = cputime - start_t;
        fprintf('------Completed task %d/%d ... of %d/%d epoch------\n', jj, nDetectors, ii, epoch);
        fprintf('------Cost time: %.2f.\n', result.tm_cost(ii,jj));
        disp('====================================');
    end
end

result.img = inImg;
result.tm_cost(end,:) = mean(result.tm_cost(1:end-1, :),1);
result.p_cost = result.tm_cost(1,:) / Nx / Ny;
disp(p_cost);
% save(tmpfile, 'result');
rmpath(datapath);