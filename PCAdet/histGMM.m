function [mu, theta, p_prior, p_post] = histGMM(h, k)

% h histogram
% k =number of component in GMM
% mu =mean value of each gaussian distribution
% theta =variance value of each gaussian distribution
% pi =prior probability of each gaussian distribution

n = length(h);
xx = 1:n;
iter = 1; MAXITER = 500; TOL =1e-15;
mu(iter,:) = xx(ceil(n/(k+1))+1:ceil(n/(k+1)):end);
theta(iter,:) = sqrt((repmat(xx, k,1) - repmat(mu(iter,:)', 1, n)).^2*h);
p_prior(iter,:) = ones(1,k)*1/k;
hn = zeros(n,k);
Lprev = inf; %上一次聚类的误差  
while iter < MAXITER
    for ii = 1:k
        hn(:,ii) = myGaussian(mu(iter,ii), theta(iter,ii), xx);
    end

    totH = hn*p_prior(iter,:)';
    L = sum((totH - h).^2);
    if  Lprev - L < TOL
        break;
    end
    Lprev = L;
%     figure(gcf);
%     plot(xx,hn,'--',xx,totH,xx,h);

    [v,i] = sort(mu(iter,:));
%     for ii = 2:k
%         interv = xx<v(ii)&xx>v(ii-1);
%         clb = [i(ii-1) i(ii)];
%         pG(interv,clb) = hn(interv,clb).*repmat(pi(iter,clb), sum(interv), 1);
%         pG(interv,clb) = pG(interv,clb)./repmat(sum(pG(interv,clb),2),1,2);
%     end
    p_post = hn.*repmat(p_prior(iter,:), n, 1);
    p_post = p_post./repmat(sum(p_post,2),1,k);
    % avoid the exceeded distribution value in the head and tail
    for ii = 1:k
        if ii == i(1)
            p_post(xx<=v(1),ii) = 1;
        else
            p_post(xx<=v(1),ii) = 0;
        end
        if ii == i(end)
            p_post(xx>=v(end),ii) = 1;
        else
            p_post(xx>=v(end),ii) = 0;
        end
    end
    p_post = p_post.*repmat(h,1,k);
    iter = iter + 1;
    
    p_prior(iter,:) = sum(p_post,1);
    mu(iter,:) = xx*p_post*diag(1./p_prior(iter,:));
    
    for ii = 1:k
        theta(iter,ii) = sqrt((xx - mu(iter,ii)).^2*p_post(:,ii)/p_prior(iter,ii));
    end
end

