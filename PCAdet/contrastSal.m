function result = contrastSal(x1, size_t)

win_width = 4;
long = size_t+win_width;
x1 = padarray(x1,[long long],'symmetric'); 
% Pfa = 0.05;
% th = (2*sqrt(-log(Pfa))-sqrt(pi))/(sqrt(4-pi)); 
[m,n]=size(x1);
result = zeros(m,n);
for ii = long:m-long
    disp(ii)
    for jj = long:n-long
        [im1,im2]=DeteImg(ii,jj,x1,size_t,win_width);
        mean1 = mean2(im1);
        std1 = std2(im1);
        mean = mean2(im2);
        ratio = (mean-mean1)/std1;
        result(ii,jj) = ratio;
    end
end

result = result(long:m-long-1,long:n-long-1);
% result(result < 3) = 3;
% result = (result - min(result(:))) / (max(result(:))- min(result(:)));