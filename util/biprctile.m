function Y = biprctile(X, p)

start_Y = min(X);
end_Y = max(X);
nbr_points = p * length(X) / 100;
crt_Y = (start_Y + end_Y) / 2;

while start_Y < end_Y - 0.005
    if sum(X>=crt_Y) > nbr_points
        start_Y  = crt_Y;
    elseif sum(X>=crt_Y) < nbr_points
        end_Y  = crt_Y;
    else
        break;
    end
    crt_Y = (start_Y + end_Y) / 2;
end
% if start_Y >= crt_Y -0.005
%     Y = start_Y;
% elseif end_Y <= crt_Y + 0.005
%     Y = end_Y;
% else
    Y = crt_Y;
% end