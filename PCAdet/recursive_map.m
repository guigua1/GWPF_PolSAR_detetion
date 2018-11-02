function img_newmap = recursive_map(img_map)

k = length(img_map);
cur_map = img_map{k};
kk = length(cur_map);
ind = zeros(kk,2);
for ii = 1:kk
    if isempty(cur_map{ii}) || sum(cur_map{ii}(:)) == 0
        ind(ii,:) = recursive_ind(img_map, k, ii);
    else
        ind(ii,:) = [k,ii];
    end
end

maps = unique(ind,'rows');
img_newmap = cell(size(maps,1),1);
for ii = 1:size(maps,1)
    img_newmap{ii} = img_map{maps(ii,1)}{maps(ii,2)};
end

function ind = recursive_ind(img_map, k, ii)
ind = [k-1, ceil(ii/3)];
if isempty(img_map{k-1}{ind(2)}) || sum(img_map{k-1}{ind(2)}(:)) == 0
    ind = recursive_ind(img_map, k-1, ind(2));
end