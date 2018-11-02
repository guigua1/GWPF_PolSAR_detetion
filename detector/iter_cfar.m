function [resultArray, resultArray2, resultArray3 ]= cfar(f, paras) 
%SAR图像CFAR目标检测算法

figure;
imshow(f,[]);

%--默认参数

pf = 0.001;                          %人为设定的恒虚警率
densGate = 40;              %密度滤波阈值
rad = 3;                        %形态学滤波结构元素半径值
numIter = 10;
tol = 1024;
width = 32;
height = 32;
if nargin == 2
    fields = fieldnames(paras);
    for i = length(fields)
        if ~isempty(paras.(fields(i)))
            eval([fields(i), '=', paras.(fields(i))]);
        end
    end
end
%--图像前期处理
f = double(f);
f_size = size(f);


%--------------------------------------------------------------------------
%        一、确定CFAR检测器参数，包括窗口尺寸，保护区宽度，杂波区宽度
%--------------------------------------------------------------------------

%--确定CFAR检测器的参数
%--1.取长宽中的最大值
global tMaxLength;
tMaxLength = max(width,height);

%--2.确定保护区的边长
global proLength;
proLength = tMaxLength*2 + 1;                           %为方便计算，取为奇数

%--3.确定杂波区环形宽度
global cLength;
cLength = 2;                                            %厚度一般为1个像素点

%--4.计算用于杂波区域的像素数
numPix = 2*cLength*(2*cLength+proLength+proLength); 

%--6.CFAR检测器边长
global cfarLength;
cfarLength = proLength + 2*cLength;
str = sprintf('CFAR检测器保护区边长：%f，杂波区环形宽度：%f，用于杂波的像素数：%f'...
              ,proLength,cLength,numPix);               %显示
disp(str);                                              %显示

%--------------------------------------------------------------------------
%         二、对原图像边界扩充，以消除边界的影响
%--------------------------------------------------------------------------
padLength = tMaxLength + cLength;           %确定图像填充的边界大小为CFAR滑窗的一半
global g;
g = padarray(f,[padLength padLength],'symmetric');      %g为填充后的图像


%--------------------------------------------------------------------------
%         三、确定CFAR阈值
%--------------------------------------------------------------------------

th = (2*sqrt(-log(pf))-sqrt(pi))/(sqrt(4-pi));  %该阈值由认为确定的虚警概率求
                                                %得

%--------------------------------------------------------------------------
%        四、利用CFAR检测器，求解局部阈值，执行单个像素点的判断
%--------------------------------------------------------------------------

%--0.定义结果处理矩阵

%--1.全局检测
global resultArray0;
resultArray0 = g > 0.5*std(g(:)) + mean(g(:));
resultArray = resultArray0;
%--2.CFAR检测
figure(2)
filename = 'test.gif';
frame = getframe(2);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imagesc(resultArray0);title('changing');axis off;
imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
%遍历图像中的每个点
for k = 1:numIter
    for i = (1+padLength):(f_size(1)+padLength)
        for j = (1+padLength):(f_size(2)+padLength)
            if ~resultArray0(i,j)
                continue;
            end
            clutter = getEstSec(i,j);
            if length(clutter) <= 10
                continue;
            end
            u = mean(clutter);
            delta = std(clutter);
            temp = (g(i,j)-u)/delta;    %计算双参数CFAR检测判别式
            %目标点判别
            if temp > th                
                resultArray(i,j) = true;
            else resultArray(i,j) = false;
            end
        end
    end
    numdif = sum(sum(xor(resultArray,resultArray0)));
    
    if  numdif< tol
        break;
    end
    disp(['The number of changed pixels: ', num2str(numdif)]);
    imagesc(resultArray0 + resultArray);
    drawnow;
    frame = getframe(2);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,filename,'gif','WriteMode','append');
    resultArray0 = resultArray;
end
%--------------------------------------------------------------------------
%                         五、目标像素聚类
%--------------------------------------------------------------------------
%--1.密度滤波
[row col] = find(resultArray);     %找到目标像素点的行列坐标
numIndex2 = numel(row);                 %确定目标点个数
resultArray2 = zeros(size(resultArray));          %resultArray2用以存放密度滤波后的矩阵
for k = 1:numIndex2                     %执行密度滤波
    resultArray2(row(k),col(k)) = densfilt(resultArray,row(k),col(k),width,height,...
                                   densGate);
end

%--2.形态学滤波
se = strel('disk',rad);
resultArray3 = imopen(resultArray2,se);        %闭运算
se = strel('disk',rad);
resultArray3 = imclose(resultArray3,se);       

%--3.展示结果图片
resultArray = resultArray((padLength+1):(end-padLength),(padLength+1):(end-padLength));
figure('Name','CFAR检测后二值图'),imshow(resultArray);
resultArray2 = resultArray2((padLength+1):(end-padLength),(padLength+1):(end-padLength));
figure('Name','密度滤波后二值图'),imshow(resultArray2);
resultArray3 = resultArray3((padLength+1):(end-padLength),(padLength+1):(end-padLength));
figure('Name','形态滤波后二值图'),imshow(resultArray3);
toc;


function sec = getEstSec(c,r)

global cLength cfarHalfLength g resultArray0;
exLen = cfarHalfLength;

allSec = resultArray0(c-exLen:c+exLen, r-exLen:r+exLen);
allSec(cLength+1:end-cLength, cLength+1:end-cLength) = true;
sec = g(c-exLen:c+exLen, r-exLen:r+exLen);
sec = sec(~(allSec));
