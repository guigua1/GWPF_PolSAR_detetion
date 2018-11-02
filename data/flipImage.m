function flipImage(path)
    files = dir(path);
    for ii = 1:length(files)
        if length(files( ii ).name) > 2
            if files(ii).isdir()
                srcPath = fullfile(path, files(ii).name, '*.png');
                flipImage(srcPath);
            else
                fileName = fullfile(path, files(ii).name);
                img = imread(fileName);
                img = fliplr(img);
                imwrite(img,fileName,'png'); 
            end
        end
    end