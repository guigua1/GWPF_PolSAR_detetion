function [q,hhmax,vhmax,vvmax,vhvv,hhvh,hhvv,count] = myHist(test1,thrsh)

q = [];
hhmax = [];vhmax = []; vvmax = [];
vhvv = []; hhvh = []; hhvv = [];
count = 0;
for ii = 1:length(test1)
    v = max(test1(ii,:));
    switch sum(test1(ii,:) >= thrsh)
        case 3
            q = [q; test1(ii,:)];
            continue;
        case 2
            [v, in] = min(test1(ii,:));
            if v < 200
                switch in
                    case 1
                        vhvv = [vhvv; test1(ii,:)];
                    case 2
                        hhvv = [hhvv; test1(ii,:)];
                    case 3
                        hhvh = [hhvh; test1(ii,:)];
                end
            end
        case 1
            if test1(ii,1) == v
                hhmax = [hhmax; test1(ii,:)];
            end
            if test1(ii,2) == v
                vhmax = [vhmax; test1(ii,:)];
            end
            if test1(ii,3) == v
                vvmax = [vvmax; test1(ii,:)];
            end
        case 0
            count = count + 1;
    end
end