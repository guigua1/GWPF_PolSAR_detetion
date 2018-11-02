function imgAll = readData(path, conditions, s)

conditions(end+1) = {'ini$'};
ntype = length(conditions) - 1;
files = listDir(path, conditions);

info = readPara(files{end}{1});
imgAll = cell(ntype, 1);
for ii = 1:ntype
    img = inputFile(files{ii}, info);
    
    fname = regexp(files{ii}{1}, conditions{ii}, 'tokens');
    fname = fname{1}{1};
    if fname
        fname = strcat(fname, '.mat');
    else
        fname = 'img.mat';
    end
    if size(img, 3) == 9
        img = transformPF(img, 99);
    end
    if exist('s', 'var') && s
        save(fullfile(path, fname), 'img');
    end
    imgAll{ii} = img;
end