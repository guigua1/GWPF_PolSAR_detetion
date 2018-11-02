function SPAN = polSpan(pF)
%% Span image
if size(pF, 2) == 3
    SPAN = sum(abs(pF).^2,2);
elseif size(pF, 2) == 9
    SPAN = sum(pF(:,[1 5 9]), 2);
end