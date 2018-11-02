function img = inputFile(paths, info)
num = length(paths);
img = [];

for ii = 1:num
    imgP = paths{ii};
    [~,imgName,fmt] = fileparts(imgP);
    if any(strcmp(fmt,{'.png'; '.jpg'; '.tiff'}))
        data = imread(imgP, fmt);
    else
        try
        fid = fopen(imgP, 'r');
        data = fread(fid, 'float');
        fclose(fid);
        data = reshape(data, info.width, info.height)';
        catch
            disp('Error: file ', imgName, ' could not be found!');
            fclose(fid);
        end
    end

    if isempty(img)
        img = data;
    else
        img = cat(3, img, data);
    end
end
%img = double(img);
