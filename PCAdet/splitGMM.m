function c_map = splitGMM(img, p_post, xx)

nc = size(p_post,2);
c_map = [];
% max_ind = ones(nc,1);
% split_ind = zeros(nc+1,1);
% intervel = xx(2)-xx(1);
% for ii = 1:nc
%     [~,max_ind(ii)] = max(p_post(:,ii));
%     
% end

[~, max_ind] = max(p_post, [], 2);
max_ind = ceil(medfilt1(max_ind, 4));
split_ind = find(diff(max_ind) ~= 0) + 1;
% split_ind(1) = xx(1)-intervel/2;
% for ii = 1:nc-1
%     [~,tmp_ind] = min(abs(p_post(max_ind(ii):max_ind(ii+1), ii) - p_post(max_ind(ii):max_ind(ii+1), ii+1)));
%     split_ind(ii+1) = xx(tmp_ind + max_ind(ii) - 1)-intervel/2;
% end
% 
% split_ind(end) = xx(end)+intervel/2;
% 
% c_map = zeros(size(img,1), nc);

if isempty(split_ind)
    return;
end

if split_ind(1) ~= 1
    split_ind = [1; split_ind];
end
if split_ind(end) ~= length(xx)
    split_ind(end+1) = length(xx);
end

c_map = false(size(img,1), nc);
for ii = 2:length(split_ind)
    x_low = xx(split_ind(ii-1)); x_high = xx(split_ind(ii));
    clss = tabulate(max_ind(split_ind(ii-1):split_ind(ii)));
    [~, i] = max(clss(:,2));
    c_map(:,i) = c_map(:,i) | (img >= x_low & img < x_high);
end

