function pwf = pwfdetect(img, th, width, posts)

if nargin == 2
    width = 35;
end
if nargin <= 3;
    posts.densf = 0;
    posts.morph = 0;
    posts.rad = 3;
end

[Nx,Ny,Nc] = size(img);

% figure;
% imshow(img);
densGate = posts.densf*width^2;              %密度滤波阈值
rad = posts.rad;                        %形态学滤波结构元素半径值

%--图像前期处理
f = double(img);

%--确定CFAR检测器的参数

%--2.确定保护区的边长
proLength = width*2 + 1;                           %为方便计算，取为奇数

%--3.确定杂波区环形宽度
cLength = 5;                                            %厚度一般为1个像素点

%--4.计算用于杂波区域的像素数
numPix = 4*cLength*(cLength+proLength); 

%--6.CFAR检测器边长
cfarLength = proLength + 2*cLength;
% str = sprintf('CFAR检测器保护区边长：%f，杂波区环形宽度：%f，用于杂波的像素数：%f'...
%               ,proLength,cLength,numPix);               %显示
% disp(str);                                              %显示

%--------------------------------------------------------------------------
%         二、对原图像边界扩充，以消除边界的影响
%--------------------------------------------------------------------------
padLength = width+cLength;           %确定图像填充的边界大小为CFAR滑窗的一半
g = padarray(f,[padLength padLength],'symmetric');      %g为填充后的图像
g = reshape(g, [], Nc);
f = reshape(f, [], Nc);
%--2.滑窗检测
cfarRegion = true(cfarLength);
cfarRegion(cLength+1:proLength, cLength+1:proLength) = false;
[r, c] = find(cfarRegion);
inds = sub2ind([Nx, Ny], r, c);

h = waitbar(0, 'sliding processing');
pwf = zeros(Nx, Ny);
for i = 1:Nx*Ny

        sec = g(i + inds, :);       %得到(i,j)处像素所对应的4个杂波估计区域，如上图所示
        
        %由杂波区域得到均值和标准偏差
        
        if Nc == 3 || Nc == 4
            %--2.行向量合并
            C = sec.' * conj(sec) / numPix;
        else
            C = reshape(mean(sec), [3 3]);
        end

        if Nc == 3
            x = squeez(f(i,:));
            pwf(i) = x'*C\x;    %计算pwf
        else
            X = reshape(f(i,:), [3 3]);
            pwf(i) = trace(C\X)+ log(det(C)); %Wishart distance
        end
    waitbar(i/Nx/Ny, h, sprintf('processing at %d / %d pixels...', i, Nx*Ny));
end
delete(h);

pwf = real(pwf);

if ~th
    return;
end

bw = false(Nx, Ny, length(th));
r = minmax(pwf(:)');
for kk = 1:length(th)
    resultArray = pwf>(th(kk) * r(2) + (1-th(kk)) * r(1));
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
        resultArray1(row(k),col(k)) = densfilt(resultArray,row(k),col(k),width,width,...
                                       densGate);
    end

    % figure('Name','密度滤波后二值图'),imshow(resultArray1);

    if ~posts.morph
        bw(:,:,kk) = resultArray1;
        continue;
    end
    %--2.形态学滤波
    se = strel('disk',rad);
    resultArray2 = imopen(resultArray1,se);
    se = strel('disk',rad);
    resultArray2 = imclose(resultArray2,se);

    % figure('Name','形态滤波后二值图'),imshow(resultArray2);

    bw(:,:,kk) = resultArray2;
end
pwf = bw;
