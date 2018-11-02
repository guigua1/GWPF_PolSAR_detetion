%% CFAR
function [im1, im2] = DeteImg(x, y, img, size, win_width)
% size = max(length,width);
im1 = [img([(x-size-win_width+1):(x-size) (x+size):(x+size+win_width-1)],(y-size):(y+size))...
            ; img((x-size):(x+size),[(y-size-win_width+1):(y-size) (y+size):(y+size+win_width-1)])'];
% im2 = img((x-floor(size/2)):(x+ceil(size/2)-1),(y-floor(size/2)):(y+ceil(size/2)-1));
im2 = img(x,y);