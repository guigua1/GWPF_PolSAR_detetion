function [ U ] = gs_Oth( A )
%GS_OTH 此处显示有关此函数的摘要
%   此处显示详细说明
%   输入原始矩阵 A
%   输出基矩阵 U
%   U的第一列为A的第一列对应的单位向量
    numF = size(A, 1);
    U = zeros(numF, rank(A));
    U(:,1) = A(:,1)/norm(A(:,1));
    curV = 2; i = 2;
    while i <= size(U,2)
        res = A(:,curV);
        for j = 1:i-1
            res = res - A(:,curV)'*U(:,j)*U(:,j);
            if norm(res) == 0
                curV = curV + 1;
                continue;
            end
        end
        U(:,i) = res/norm(res);
        i = i + 1;
    end
end

