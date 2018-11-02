function value = densfilt(img, r,c,width,height,densGate)
%   value=densfilt(r,c,width,height,densGate)，r、c分别代表测试像素的行和列；
%   width、height分表代表滤波矩形模板的宽和高，densGate代表滤波阈值，value值
%   是判别结果

a = ceil(height/2);
b = ceil(width/2);
%--1.计算以测试像素为中心的滤波矩形模板的位置
rStart = max(r - a, 1);
rEnd = min(r + a, size(img,1));
cStart = max(c - b, 1);
cEnd = min(c + b, size(img,2));

%--2.得到矩形模型模板中的目标像素数
densSection = img(rStart:rEnd,cStart:cEnd);
num = sum(densSection(:));
%--3.判断滤波
if num >= densGate
    value = true;
else
    value = false;
end