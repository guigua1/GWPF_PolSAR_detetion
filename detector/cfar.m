function outImg = cfar(img, th, width, posts)

if nargin == 2
    width = 32;
end
if nargin <= 3;
    posts.densf = 0;
    posts.morph = 0;
    posts.rad = 3;
end
[Nx,Ny,Nc] = size(img);
assert(Nc == 1, 'Only for graylevel image!');
% figure;
% imshow(img);


%--图像前期处理
f = double(img);

%--确定CFAR检测器的参数

%--1.确定保护区的边长
proLength = width*2 + 1;                           %为方便计算，取为奇数

%--2.确定杂波区环形宽度
global cLength;
cLength = 2;                                            %厚度一般为1个像素点

global cfarHalfLength;
cfarHalfLength = width + cLength;

%--3.CFAR检测器边长
% cfarLength = proLength + 2*cLength;
str = sprintf('CFAR检测器保护区边长：%f，杂波区环形宽度：%f.'...
              ,proLength,cLength);               %显示
disp(str);                                              %显示

%--------------------------------------------------------------------------
%         二、对原图像边界扩充，以消除边界的影响
%--------------------------------------------------------------------------
padLength = cfarHalfLength;           %确定图像填充的边界大小为CFAR滑窗的一半
global g;
g = padarray(f,[padLength padLength],'symmetric');      %g为填充后的图像

%--1.全局检测
global g_det;
g_det = g > 0.5*std(g(:)) + mean(g(:));

%--2.滑窗检测
% h = waitbar(0, 'sliding processing');
outImg = zeros(Nx, Ny);
for i = 1:Nx
    for j = 1:Ny
        if ~g_det(i+padLength,j+padLength)
            continue;
        end
        outImg(i, j) = cfarWindow(i+padLength,j+padLength);
    end
%     waitbar(i/Nx, h, sprintf('processing at %d / %d row...', i, Nx));
end
% delete(h)

if ~th
    return;
end

densGate = posts.densf*width^2;              %密度滤波阈值
r = minmax(outImg(:));
for kk = 1:length(th)
    resultArray = outImg >(th(kk) * r(2) + (1-th(kk)) * r(1));
    if ~posts.densf
        bw(:,:,kk) = resultArray;
        continue;
    end
    %--------------------------------------------------------------------------
    %                         五、目标像素聚类
    %--------------------------------------------------------------------------
    %--1.密度滤波
    [row, col] = find(resultArray);     %找到目标像素点的行列坐标
    numIndex2 = numel(row);                 %确定目标点个数
    resultArray1 = zeros(size(resultArray));          %resultArray2用以存放密度滤波后的矩阵
    for k = 1:numIndex2                     %执行密度滤波
        resultArray1(row(k),col(k)) = densfilt(resultArray,row(k),col(k), width, width, densGate);
    end

    % figure('Name','密度滤波后二值图'),imshow(resultArray1);

    if ~posts.morph
        bw(:,:,kk) = resultArray1;
        continue;
    end
    %--2.形态学滤波
    rad = posts.rad;     
    se = strel('disk',rad);
    resultArray2 = imopen(resultArray1,se);
    se = strel('disk',rad);
    resultArray2 = imclose(resultArray2,se);

    % figure('Name','形态滤波后二值图'),imshow(resultArray2);

    bw(:,:,kk) = resultArray2;
end

outImg = bw;

function output = cfarWindow(c,r)

global cLength cfarHalfLength g g_det;
exLen = cfarHalfLength;

allSec = g_det(c-exLen:c+exLen, r-exLen:r+exLen);
allSec(cLength+1:end-cLength, cLength+1:end-cLength) = true;
sec = g(c-exLen:c+exLen, r-exLen:r+exLen);
sec = sec(~(allSec));
output = (g(c,r) - mean(sec)) / std(sec);   %计算双参数CFAR检测判别式
