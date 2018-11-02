function files = listDir(path, conditions)

fs = dir(path); count = zeros(length(conditions),1);
for ii = 3:length(fs)
    for jj = 1:length(conditions);
        if regexp(fs(ii).name, conditions{jj}, 'once');
            count(jj) = count(jj) + 1;
            files{jj}{count(jj),1} = fullfile(path, fs(ii).name);
            break;
        end
    end
end