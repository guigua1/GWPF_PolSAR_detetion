function[entropy,alpha,anisotropy,pd]=eigen_decomposition(t11,t22,t33,t12,t13,t23,data_flag,show_result)
%%%  data_flag='C' 时使用的协方差矩阵数据，data_flag='T' 时使用相干矩阵数据
%%%  结果为特征分解后的图像（熵，散射角(0-1)和反熵） 
if nargin==6
    data_flag='C';
    show_result=1;
elseif nargin==7
    show_result=1;
end
B=[1 0 1;1 0 -1;0 1.414 0]/1.414;%%%  inv(B)=B'
[size1,size2]=size(t11);
if data_flag=='C'
	for jj=1:size1
        for kk=1:size2
            temp_cov=[t11(jj,kk),t12(jj,kk),t13(jj,kk);t12(jj,kk)',t22(jj,kk),t23(jj,kk);t13(jj,kk)',t23(jj,kk)',t33(jj,kk)]; % 协方差矩阵
            T=B*temp_cov*B';% 转换为特征矩阵
            [V,D]=eigs(T);
            D=abs(D);
            p=D(1,1)+D(2,2)+D(3,3);
            p3=abs(D(3,3))/p;
            p2=abs(D(2,2))/p;
            p1=abs(D(1,1))/p;%%%%  最大
            entropy(jj,kk)=(-(p1*log(p1)+p2*log(p2)+p3*log(p3)))/log(3);%%  熵值
            alpha(jj,kk)=(acos(abs(V(1,3)))*p3+acos(abs(V(1,2)))*p2+acos(abs(V(1,1)))*p1)*2/pi;%%%%  归一化了
            anisotropy(jj,kk)=(p2-p3)/(p3+p2);
            pd(jj,kk)=(p1-p2)/(p1+p2);
        end
	end
elseif data_flag=='T'
	for jj=1:size1
        for kk=1:size2
            T=[t11(jj,kk),t12(jj,kk),t13(jj,kk);t12(jj,kk)',t22(jj,kk),t23(jj,kk);t13(jj,kk)',t23(jj,kk)',t33(jj,kk)]; % 相干矩阵
            [V,D]=eigs(T);
            D=abs(D);
            p=D(1,1)+D(2,2)+D(3,3);
            p3=abs(D(3,3))/p;
            p2=abs(D(2,2))/p;
            p1=abs(D(1,1))/p;%%%%  最大值
            entropy(jj,kk)=(-(p1*log(p1)+p2*log(p2)+p3*log(p3)))/log(3);%%  熵值
            alpha(jj,kk)=(acos(abs(V(1,3)))*p3+acos(abs(V(1,2)))*p2+acos(abs(V(1,1)))*p1)*2/pi;%%%%  归一化了的散射角
            anisotropy(jj,kk)=(p2-p3)/(p3+p2);   %%%  反熵
            pd(jj,kk)=(p1-p2)/(p1+p2);
        end
	end
end
if show_result
	figure; imshow(entropy);title('entropy');
	figure; imshow(alpha);title('alpha');
	figure; imshow(anisotropy);title('anisotropy');
    figure; imshow(pd);title('pd');
end