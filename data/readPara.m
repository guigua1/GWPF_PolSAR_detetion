function [info] = readPara(parafile)

try
    infof = fopen(parafile, 'r');
    while ~feof(infof)
        tline = fgetl(infof);
        c = strsplit(tline, ':');
        info.(c{1}) = str2double(c{2});
    end
catch
    disp('Error: file could not be found!');
    fclose(infof);
end
fclose(infof);