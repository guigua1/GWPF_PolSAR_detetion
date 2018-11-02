function displayPf(data, info, method)

if size(data,2) == 1
    figure; imshow(reshape(data, info.height, info.width),[]);
    return;
end

switch method
    case 'pauli'
        data = data(:, [2 3 1]);
end        
data = reshape(data/max(data(:)), info.height, info.width, []);

figure; imshow(data);